function onRequest(request, response, modules) {
    var db = modules.oData;
    //tableName是需要用到排序的表名，可以根据你的实际情况更换
    var tableName = "Room1";
    //这个objectId可以通过request.body.参数名 从SDK中传上来
    var objectId = request.body.objectId;
    //获取表"Room1"的所有数据，找出过期的数据删除

    db.find({
        "table": tableName,
        // "limit":0,    不注释的话只获得记录数，否则返回整个表
        "count": 1
    }, function(err, data) {
        // response.send("data:"+data);
        resultObject = JSON.parse(data);
        count = resultObject.count;
        //    response.send("表记录数:"+count);
        if (count == 0) { //0条记录直接插入一条新数据
            db.insert({
                "table": tableName, //表名
                "data": {
                    "user1": objectId,
                    "userCount": 1
                } //需要更新的数据，格式为JSON
            }, function(err, data) { //回调函数
                var resultObject = JSON.parse(data);
                var oId = resultObject.objectId;
                response.send('{"ret":0,"objectId":oId}');
            });
        } else { //不是空的，则遍历表找出过期房间删除
            for (var i = 0; i < count; i++) {
                var updateDate = new Date(resultObject.results[i].updatedAt);
                var curDate = new Date();
                var updateDatetamp = Date.parse(updateDate);
                var curDatetamp = Date.parse(curDate);
                var detaltamp = (curDatetamp - updateDatetamp) / 1000;

                if (detaltamp > 60) {
                    // response.send('resultObject.results[i].objectId:'+resultObject.results[i].objectId);
                    db.remove({
                        "table": tableName, //表名
                        "objectId": resultObject.results[i].objectId, //记录的objectId
                    }, function(err, data) { //回调函数
                    });
                }
            }
            //删了一遍后，查询适合的房间
            db.find({
                "table": tableName,
                "limit": 0,
                "count": 1
            }, function(err, data) {
                if (count == 0) { //oh no 删完了~ 直接插一个
                    db.insert({
                        "table": tableName, //表名
                        "data": {
                            "user1": objectId,
                            "userCount": 1
                        } //需要更新的数据，格式为JSON
                    }, function(err, data) { //回调函数
                        var resultObject = JSON.parse(data);
                        var oId = resultObject.objectId;
                        response.send('{"ret":0,"objectId":' + 'oId}');
                        // response.send("insert:"+data);
                    });
                } else {
                    db.find({
                        "table": tableName,
                        "keys": "objectId", //返回字段列表，多个字段用,分隔
                        "where": {
                            userCount: {
                                "$lte": 5
                            }
                        }, //查询条件是一个JSON object
                        "order": "updatedAt", //排序列表，[-]字段名称,-表示降序，默认为升序
                        "count": 1
                    }, function(err, data) {
                        var jsonData = JSON.parse(data);
                        var oId = jsonData.results[0].objectId
                        response.send('{"ret":0,"objectId":' + oId + '}');
                        // response.send("find:"+oId);
                    });
                }
            });
        }
    });
}