from http.server import BaseHTTPRequestHandler,HTTPServer
import json
from passlib.hash import sha256_crypt
import pyodbc
import random
from datetime import datetime

conn = pyodbc.connect('Driver={SQL Server};'
                      'Server=VIRAJ-PC\SQLEXPRESS;'
                      'Database=locationSharing;'
                      'Trusted_Connection=yes;')
cursor = conn.cursor()
PORT_NUMBER = 8080

class myHandler(BaseHTTPRequestHandler):
    def httpReply(self, response):
        rJ= json.dumps(response)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(rJ.encode())
    
    def do_GET(self):
        if self.path=='/':
            self.send_response(200)
            self.end_headers()
            self.wfile.write('Get recieved'.encode())

    def do_POST(self):
        if self.path=='/login':
            content_length = int(self.headers['Content-Length'])
            f=self.rfile.read(content_length)
            fs=f.decode()
            fDict=json.loads(fs)

            cursor.execute("select * from usersTable where username like '%s';" % (fDict['user']) )
            try:
                data=cursor.fetchall()[0]
                if data[2] == None:
                    if sha256_crypt.verify(fDict['password'], data[1]):
                        commPass = random.randint(0,9999)
                        cursor.execute("update usersTable set commPassword = '%s' where username like '%s';" % (commPass, fDict['user']) )
                        conn.commit()
                        self.httpReply({"reply":"pass","commPass":str(commPass)})
                    else:
                        self.httpReply({"reply":"fail","error":"incorrect password"})
                else:
                    self.httpReply({"reply":"fail","error":"Please log out from other devices"})

            except IndexError:
                self.httpReply({"reply":"fail","error":"user doesnt exist"})

        elif self.path=='/signup':
            content_length = int(self.headers['Content-Length'])
            f=self.rfile.read(content_length)
            fs=f.decode()
            fDict=json.loads(fs)

            cursor.execute("select * from usersTable where username like '%s';" % (fDict['user']) )
            data=cursor.fetchall()
            
            if len(data) != 0:
                self.httpReply({"reply":"fail","error":"user already exists"})
            elif ',' in fDict['user']:
                self.httpReply({"reply":"fail","error":"do not use commas"})
            else:
                password = str(sha256_crypt.hash(fDict['password']))
                socialNum = random.randint(0,9999)
                cursor.execute("insert into usersTable values ('%s', '%s', NULL, NULL, NULL, NULL, '%s');" % (fDict['user'], password, socialNum) )
                conn.commit()
                self.httpReply({"reply":"pass"})

        elif self.path=='/logout':
            content_length = int(self.headers['Content-Length'])
            f=self.rfile.read(content_length)
            fs=f.decode()
            fDict=json.loads(fs)

            cursor.execute("select * from usersTable where username like '%s';" % (fDict['user']) )
            data=cursor.fetchall()[0]

            if data[2] == fDict['commPass']:
                self.httpReply({"reply":"pass"})
                cursor.execute("update usersTable set commPassword = NULL where username like '%s';" % (fDict['user']) )
                conn.commit()
            else:
                self.httpReply({"reply":"fail","error":"malicious intent"})

        elif self.path=='/getfriends':
            content_length = int(self.headers['Content-Length'])
            f=self.rfile.read(content_length)
            fs=f.decode()
            fDict=json.loads(fs)

            cursor.execute("select * from usersTable where username like '%s';" % (fDict['user']) )
            data=cursor.fetchall()[0]

            if data[2] == fDict['commPass']:
                try:
                    if data[3]==None: data[3]=''
                    if data[3][0]==',': data[3] = data[3][1:]
                except IndexError:
                    data[3]=''
                self.httpReply({"reply":"pass","friends":data[3]})
            else:
                self.httpReply({"reply":"fail","error":"malicious intent"})

        elif self.path=='/removefriend':
            content_length = int(self.headers['Content-Length'])
            f=self.rfile.read(content_length)
            fs=f.decode()
            fDict=json.loads(fs)

            cursor.execute("select * from usersTable where username like '%s';" % (fDict['user']) )
            data=cursor.fetchall()[0]

            if data[2] == fDict['commPass']:
                friendsStr = data[3]
                friends = friendsStr.split(',')
                friends.remove(fDict['target'])
                friendsStr = listToStrSpecial(friends)
                cursor.execute("update usersTable set friends = '%s' where username like '%s';" % (friendsStr, fDict['user']) )
                conn.commit()

                cursor.execute("select * from usersTable where username like '%s';" % (fDict['target']) )
                data2=cursor.fetchall()[0]
                friendsStr = data2[3]
                friends = friendsStr.split(',')
                friends.remove(fDict['user'])
                friendsStr = listToStrSpecial(friends)
                cursor.execute("update usersTable set friends = '%s' where username like '%s';" % (friendsStr, fDict['target']) )
                conn.commit()

                self.httpReply({"reply":"pass"})
            else:
                self.httpReply({"reply":"fail","error":"malicious intent"})

        elif self.path=='/addfriend':
            content_length = int(self.headers['Content-Length'])
            f=self.rfile.read(content_length)
            fs=f.decode()
            fDict=json.loads(fs)

            cursor.execute("select * from usersTable where username like '%s';" % (fDict['user']) )
            data=cursor.fetchall()[0]

            if data[2] == fDict['commPass']:
                cursor.execute("select * from usersTable where socialCode like '%s';" % (fDict['target']) )
                data2=cursor.fetchall()

                if len(data2)==0:
                    self.httpReply({"reply":"fail","error":"Invalid Code"})
                else:
                    if data[3] != None:
                        friendsStr = data[3]
                        friends = friendsStr.split(',')
                    else:
                        friends = []

                    if data2[0][0] in friends:
                        self.httpReply({"reply":"fail","error":"Already added as a friend"})
                    else:
                        friends.append(data2[0][0])
                        friendsStr = listToStrSpecial(friends)
                        cursor.execute("update usersTable set friends = '%s' where username like '%s';" % (friendsStr, fDict['user']) )
                        conn.commit()

                        if data2[0][3] != None:
                            friendsStr2 = data2[0][3]
                            friends2 = friendsStr2.split(',')
                        else:
                            friends2 = []
                            
                        friends2.append(fDict['user'])
                        friendsStr2 = listToStrSpecial(friends2)
                        cursor.execute("update usersTable set friends = '%s' where username like '%s';" % (friendsStr2, data2[0][0]) )
                        conn.commit()

                        self.httpReply({"reply":"pass"})
            else:
                self.httpReply({"reply":"fail","error":"malicious intent"})

        elif self.path=='/getsocialcode':
            content_length = int(self.headers['Content-Length'])
            f=self.rfile.read(content_length)
            fs=f.decode()
            fDict=json.loads(fs)

            cursor.execute("select * from usersTable where username like '%s';" % (fDict['user']) )
            data=cursor.fetchall()[0]

            if data[2] == fDict['commPass']:
                self.httpReply({"reply":"pass","socialCode":data[6]})
            else:
                self.httpReply({"reply":"fail","error":"malicious intent"})

        elif self.path=='/changesocialcode':
            content_length = int(self.headers['Content-Length'])
            f=self.rfile.read(content_length)
            fs=f.decode()
            fDict=json.loads(fs)

            cursor.execute("select * from usersTable where username like '%s';" % (fDict['user']) )
            data=cursor.fetchall()[0]

            if data[2] == fDict['commPass']:
                socialNum = random.randint(0,9999)
                cursor.execute("update usersTable set socialCode = '%s' where username like '%s';" % (socialNum, fDict['user']) )
                conn.commit()
                self.httpReply({"reply":"pass"})
            else:
                self.httpReply({"reply":"fail","error":"malicious intent"})

        elif self.path=='/getfriendlocation':
            content_length = int(self.headers['Content-Length'])
            f=self.rfile.read(content_length)
            fs=f.decode()
            fDict=json.loads(fs)

            cursor.execute("select * from usersTable where username like '%s';" % (fDict['user']) )
            data=cursor.fetchall()[0]

            if data[2] == fDict['commPass']:
                cursor.execute("select * from usersTable where username like '%s';" % (fDict['target']) )
                data2=cursor.fetchall()[0]
                latlng = data2[4]
                latlngLS = latlng.split(',')
                lastSeen = data2[5]
                self.httpReply({"reply":"pass","lat":latlngLS[0],"lng":latlngLS[1],"lastSeen":data2[5]})
                
            else:
                self.httpReply({"reply":"fail","error":"malicious intent"})

        elif self.path=='/uploadlocation':
            content_length = int(self.headers['Content-Length'])
            f=self.rfile.read(content_length)
            fs=f.decode()
            fDict=json.loads(fs)

            cursor.execute("select * from usersTable where username like '%s';" % (fDict['user']) )
            data=cursor.fetchall()[0]

            if data[2] == fDict['commPass']:
                latlng = fDict['lat']+','+fDict['lng']
                cursor.execute("update usersTable set lastLocation = '%s' where username like '%s';" % (latlng, fDict['user']) )
                conn.commit()
                
                now = datetime.now()
                lastSeen = now.strftime("%d/%m/%Y %H:%M:%S")
                cursor.execute("update usersTable set lastSeen = '%s' where username like '%s';" % (lastSeen, fDict['user']) )
                conn.commit()

                self.httpReply({"reply":"pass"})
            else:
                self.httpReply({"reply":"fail","error":"malicious intent"})

        elif self.path=='/postTest':
            content_length = int(self.headers['Content-Length'])
            f=self.rfile.read(content_length)
            fs=f.decode()
            fDict=json.loads(fs)
            print(fDict)
            self.httpReply({"reply":"pass","number":str(random.randint(0,100))})

def listToStrSpecial(ls):
    base = ''
    for i in ls:
        base = base + i + ','
    return base[:-1]

try:
	server = HTTPServer(('10.117.154.165', PORT_NUMBER), myHandler)
	print ('Started httpserver on port ' , PORT_NUMBER)
	server.serve_forever()

except KeyboardInterrupt:
	print ('^C received, shutting down the web server')
	server.socket.close()
