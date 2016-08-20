package com.lzstudio.googlepay;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.util.Log;

import com.lzstudio.common.ActivityBase;
import com.lzstudio.common.Component;

public class GooglePayJavaBridge {
	private static String TAG = GooglePayJavaBridge.class.getSimpleName();
	
	private static int callLuaSetupCallbackId = -1;
	private static int callLuaLoadGoodsCallbackId = -1;
	private static int callLuaRechargeCallbackId = -1;
	private static int callLuaDeliveryCallbackId = -1;
	private static int callLuaConsumeCallbackId = -1;

	private static GooglePayComponent getCompon(){
		if(ActivityBase.getContext() != null){
			List<Component> compons = ActivityBase.getContext().getComponentManager().findComponent(GooglePayComponent.class);
			if(compons != null && compons.size() > 0){
				return (GooglePayComponent) compons.get(0);
			}
		}
		return null;
	}
	
//-------------------------- lua 2 java --------------------------
	public static void setDeliveryCallback(int luaFunctionId){
		if(callLuaDeliveryCallbackId != -1){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callLuaDeliveryCallbackId);
			callLuaDeliveryCallbackId = -1;
		}
		callLuaDeliveryCallbackId = luaFunctionId;
	}	
	
	public static String isSetuped(){
		final GooglePayComponent compon = getCompon();
		if(compon != null){
			return String.valueOf(compon.isSetuped());
		}
		return "false";
	}
	
	public static String isSupported(){
		final GooglePayComponent compon = getCompon();
		if(compon != null){
			return String.valueOf(compon.isSupported());
		}
		return "false";
	}
	
	//开始sdk流程
	public static void startSetup(int luaFunctionId){
		Log.d(TAG, "java bridge startSetup");
		if(callLuaSetupCallbackId != -1){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callLuaSetupCallbackId);
			callLuaSetupCallbackId = -1;
		}
		callLuaSetupCallbackId = luaFunctionId;
		
		final GooglePayComponent compon = getCompon();
		if(compon != null){
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					compon.startSetup();
				}
			});
		}
	}
	
	//查询并且load商品数据
	public static void loadingGoods(int luaFunctionId, final String goods){
		Log.d(TAG, "java bridge loading goods");
		if(callLuaLoadGoodsCallbackId != -1){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callLuaLoadGoodsCallbackId);
			callLuaLoadGoodsCallbackId = -1;
		}
		callLuaLoadGoodsCallbackId = luaFunctionId;		
		
		final GooglePayComponent compon = getCompon();
		if(compon != null){
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					compon.loadingGoods(goods);
				}
			});
		}
	}
	
	//消费商品
	public static void consume(int luaFunctionId, final String sku){
		if(callLuaConsumeCallbackId != -1){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callLuaConsumeCallbackId);
			callLuaConsumeCallbackId = -1;
		}
		callLuaConsumeCallbackId = luaFunctionId;			
		
		final GooglePayComponent compon = getCompon();
		if(compon != null){
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					compon.consume(sku);
				}
			});
		}
	}
	
	//购买商品
	public static void recharge(int luaFunctionId, final String skuData){
		if(callLuaRechargeCallbackId != -1){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callLuaRechargeCallbackId);
			callLuaRechargeCallbackId = -1;
		}
		callLuaRechargeCallbackId = luaFunctionId;
		
		final GooglePayComponent compon = getCompon();
		if(compon != null){
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					compon.recharge(skuData);
				}
			});
		}
	}
//-------------------------- lua 2 java end --------------------------
	
	//dispose
	public static void dispose(){
		final GooglePayComponent compon = getCompon();
		if(compon != null){
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					compon.dipose();
				}
			});
		}
	}
	
//-------------------------- java 2 lua --------------------------
	static void setupOnLua(final String value){
		Log.d(TAG, "callback setup funcId:" + callLuaSetupCallbackId + ",value:" + value);
		if(callLuaSetupCallbackId != -1){
			ActivityBase.getContext().runOnGLThread(new Runnable() {
				
				@Override
				public void run() {
					Log.d(TAG, "callback setup 2");
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaSetupCallbackId, value);
				}
			});
		}
	}
	
	static void loadGoodsOnLua(final String value){
		if(callLuaLoadGoodsCallbackId != -1){
			ActivityBase.getContext().runOnGLThread(new Runnable() {
				
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaLoadGoodsCallbackId, value);
				}
			});
		}
	}
	
	static void rechargeOnLua(final String value){
		if(callLuaRechargeCallbackId != -1){
			ActivityBase.getContext().runOnGLThread(new Runnable() {
				
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaRechargeCallbackId, value);
				}
			});
		}
	}
	
	static void deliveryOnLua(final String value){
		if(callLuaDeliveryCallbackId != -1){
			ActivityBase.getContext().runOnGLThread(new Runnable() {
				
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaDeliveryCallbackId, value);
				}
			});
		}
	}	
	
	static void consumeOnLua(final String value){
		if(callLuaConsumeCallbackId != -1){
			ActivityBase.getContext().runOnGLThread(new Runnable() {
				
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaConsumeCallbackId, value);
				}
			});
		}		
	}
}

//-------------------------- java 2 lua end --------------------------
