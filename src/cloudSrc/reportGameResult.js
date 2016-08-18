function onRequest(request, response, modules) {
    var db = modules.oData;
    var user = eval("(" + request.body.user + ")");
    var robot = eval("(" + request.body.robot + ")");
    var gameResult = eval("(" + request.body.gameResult + ")");

    if (user.betMoney > 0){

        db.insert({
          "table":"GameRecord",
          "data":{"uid":user.objectId,"resultNum":gameResult.resultNum,"profit":gameResult.profit,"userBetMoney":user.betMoney,"userBetNumber":user.userBetNumber}
        },function(err,data){
        });
    }

    for (var i = 0; i < 5; i++){
        if (robot[i].isEmpty != 1){ //这个位置有机器人所以要刷新这货
            db.update({
              "table":"Robot",
              "objectId":robot[i].objectId,
              "data":{"money":robot[i].money}
            },function(err,data){
            });
        }
    }

    response.send('{"ret":0}');
}
                                                                                                                                                                
