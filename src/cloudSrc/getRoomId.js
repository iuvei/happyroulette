function onRequest(request, response, modules) {
    var db = modules.oData;
    var tableName = "Room";//request.body.roomId;
    var objectId = request.body.objectId;

     db.findOne({
        "table": tableName,
        "userId": objectId,
        "keys": "objectId", //返回字段列表，多个字段用,分隔
        },  
        "count": 1
    }, function(err, data) {
        var resultObject = JSON.parse(data);
        var oId = resultObject.objectId;
        response.send('{"ret":"0","objectId":"' + oId + '"}');
    });

     db.insert({
        "table": tableName, //表名
        "data": {
            "userId": objectId,
            "userCount": 1
        } //需要更新的数据，格式为JSON
    }, function(err, data) { //回调函数
        var resultObject = JSON.parse(data);
        var oId = resultObject.objectId;
        response.send('{"ret":"0","objectId":"' + oId + '"}');
    });
}                                                                                                                       