function onRequest(request, response, modules) {
    var db = modules.oData;
    //判断是否重新生成排行榜
    db.findOne({
        "table": "GameConfig",
        "objectId": "jxnO666T",
    }, function(err, data) {
    	var gameConfig = JSON.parse(data);
        var lastDay = gameConfig.rank_updateAt+''
        var myDate = new Date();
        var curDay = myDate.getDate()+'';
        // response.send('lastDay = '+lastDay+',curDay = '+curDay);
        if (curDay != lastDay){//重新生成
            db.find({
                "table":"Rank",
                "count":1
            },function(err,data){
                var rankObject = JSON.parse(data);
                count = rankObject.count;
                for (var i = 0; i < count; i++) {
                    db.remove({
                        "table":"Rank",             //表名
                        "objectId":''+rankObject.results[i].objectId        //记录的objectId
                    },function(err,data){         //回调函数
                    });
                }
            });

            db.find({
                "table":"_User",
                "count":1
            },function(err,data){
                 var userObject = JSON.parse(data);
                 count = userObject.count;
		         for (var i = 0; i < count; i++) {
                     db.insert({
                      "table":"Rank",
                      "objectId":userObject.results[i].objectId,
                      "data":{"money":userObject.results[i].money,"nickName":userObject.results[i].nickName,"icon":userObject.results[i].icon}
                    },function(err,data){

                    });
                 }
            });

            db.find({
                "table":"Robot",
                "count":1
            },function(err,data){
                 var userObject = JSON.parse(data);
                 count = userObject.count;
		         for (var i = 0; i < count; i++) {
                     db.insert({
                      "table":"Rank",
                      "objectId":userObject.results[i].objectId,
                      "data":{"money":userObject.results[i].money,"nickName":userObject.results[i].nickName,"icon":userObject.results[i].icon}
                    },function(err,data){

                    });
                 }
            });

            db.update({
                "table": "GameConfig",
                "objectId": "jxnO666T",
                "data":{"rank_updateAt":''+curDay}
            }, function(err, data) {

            });

            //返回当前的排行榜
            db.find({
                "table":"Rank",
                "where": {
                            money: {
                                "$gte":1000000
                            }
                        },       //查询条件是一个JSON object
                "order":"-money",         //排序列表，[-]字段名称,-表示降序，默认为升序
                "limit":10,
                "count":1,
            },function(err,data){
                response.send(data);
            });

        }else{//返回当前的排行榜
            db.find({
                "table":"Rank",
                "where": {
                            money: {
                                "$gte":1000000
                            }
                        },       //查询条件是一个JSON object
                "order":"-money",         //排序列表，[-]字段名称,-表示降序，默认为升序
                "limit":10,
                "count":1,
            },function(err,data){
                response.send(data);
            });
        }
    });
}                                        
