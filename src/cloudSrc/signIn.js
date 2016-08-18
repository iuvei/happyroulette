function onRequest(request, response, modules) {
    var db = modules.oData;
    var username = request.body.username;
    var password = '666666';
    db.userLogin({
        "username":username,
        "password":password
    },function(err, data){
        // response.send(data);
        if(data){
            var user = JSON.parse(data);
            if(user.error == null){
                var signInDate = user.signInDate;
            	if (signInDate == null){
            	    signInDate = 0;
            	}
            	var signInDay = user.signInDay;
            	if (signInDay == null){
            	    signInDay = 0;
            	}
            	var money = user.money;
            	var myDate = new Date();
                var curDay = myDate.getDate();
                var values = [1000,2000,3000,5000,7000,9000,15000];
                if (signInDate != curDay){
                    var dayIdx = signInDay + 1;
                    if (dayIdx > 7){dayIdx = 1;}
                    if (dayIdx < 1){dayIdx = 1;}
                    var newMoney = money + values[dayIdx - 1];
                    db.userLogin({
                      "username":username,            //登录用户名
                      "password":password,              //用户密码
                    },function(err,data){         //回调函数
                        // response.send(data);
                        db.setHeader({"x-bmob-session-token":user.sessionToken});
                        db.updateUserByObjectId({//更新刷新时间
                                    "objectId": user.objectId,
                                    "data":{"money":newMoney,"signInDate":curDay,"signInDay":dayIdx}
                        }, function(err, data) {
                            // response.send(data);

                             response.send('{"ret":0}');
                        });
                    });
                }else{
                     response.send('{"ret":-1}');
                }
            }else{
                response.send('{"ret":-2}');
            }
        }else{
           response.send('{"ret":-3}');
        }
    });
}                                        
