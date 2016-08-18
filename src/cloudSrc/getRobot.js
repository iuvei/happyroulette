function onRequest(request, response, modules) {
   	var db = modules.oData;
    var tableName = "Robot";
    //查找
    db.find({
        "table": tableName,
        // "limit":0,    不注释的话只获得记录数，否则返回整个表
        "count": 1
    }, function(err, data) {
    	resultObject = JSON.parse(data);
        count = resultObject.count;
		for (var i = 0; i < count; i++) {
		    var updateDate = new Date(resultObject.results[i].updatedAt);
		    var curDate = new Date();
		    var updateDatetamp = Date.parse(updateDate);
		    var curDatetamp = Date.parse(curDate);
		    var detaltamp = (curDatetamp - updateDatetamp) / 1000;

		    if (detaltamp > 60) {

		    	if (resultObject.results[i].money < 10000){
		    		resultObject.results[i].money = resultObject.results[i].money + Math.ceil(Math.random()*10)*Math.ceil(Math.random()*10)*1000000
		    	}

		    	db.update({
				  "table":tableName,             //表名
				  "objectId":resultObject.results[i].objectId,        //记录的objectId
				  "data":{"updateItem":"0","money":resultObject.results[i].money}           //需要更新的数据，格式为JSON
				},function(err,data){         //回调函数
				});
		    	response.send('{"ret":"0","objectId":"' + resultObject.results[i].objectId + '"}');
		    	break;
		    }
		}
		response.send('{"ret":"-1"}');
    });
}                                         