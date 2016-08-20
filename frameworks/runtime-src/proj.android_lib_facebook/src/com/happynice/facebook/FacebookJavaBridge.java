package com.happynice.facebook;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import com.happynice.common.ActivityBase;
import com.happynice.common.Component;

public class FacebookJavaBridge {
	private static final String TAG = FacebookJavaBridge.class.getSimpleName();
	
	private static int callLuaLoginCallbackId = -1;
	private static int callLuaGetInvitableFriendsCbId = -1;
	private static int callLuaInviteCallbackId = -1;
	private static int callLuaShareCallbackId = -1;
	private static int callLuaGetRequestIdCbId = -1;
	
	private static FacebookComponent getCompon(){
		if(ActivityBase.getContext() != null){
			List<Component> compons = ActivityBase.getContext().getComponentManager().findComponent(FacebookComponent.class);
			if(compons != null && compons.size() > 0){
				return (FacebookComponent) compons.get(0);
			}
		}
		return null;
	}
	
	//lua调用java
	public static void login(int luaFunctionId){
		if(callLuaLoginCallbackId != -1){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callLuaLoginCallbackId);
			callLuaLoginCallbackId = -1;
		}
		callLuaLoginCallbackId = luaFunctionId;
		
		final FacebookComponent compon = getCompon();
		if(compon != null){
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					compon.login();
				}
			});
		}
	}
	
	public static void logout(){
		final FacebookComponent compon = getCompon();
		if(compon != null){
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					compon.logout();
				}
			});
		}
	}
	
	public static void getInvitableFriends(int luaFunctionId){
		if(callLuaGetInvitableFriendsCbId != -1){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callLuaGetInvitableFriendsCbId);
			callLuaGetInvitableFriendsCbId = -1;
		}
		callLuaGetInvitableFriendsCbId = luaFunctionId;
		
		final FacebookComponent compon = getCompon();
		if(compon != null){
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					compon.getInvitableFriends();
				}
			});
		}
	}
	
	public static void invite(final String inviteData, int luaFunctionId){
		if(callLuaInviteCallbackId != -1){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callLuaInviteCallbackId);
			callLuaInviteCallbackId = -1;
		}
		callLuaInviteCallbackId = luaFunctionId;
		
		final FacebookComponent compon = getCompon();
		if(compon != null){
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					compon.invite(inviteData);
				}
			});
		}
	}
	
	public static void share(final String shareData, int luaFunctionId){
		if(callLuaShareCallbackId != -1){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callLuaShareCallbackId);
			callLuaShareCallbackId = -1;
		}
		callLuaShareCallbackId = luaFunctionId;
		
		final FacebookComponent compon = getCompon();
		if(compon != null){
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					compon.share(shareData);
				}
			});
		}
	}
	
	public static void getAppRequestsId(int luaFunctionId){
		if(callLuaGetRequestIdCbId != -1){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callLuaGetRequestIdCbId);
			callLuaGetRequestIdCbId = -1;
		}
		callLuaGetRequestIdCbId = luaFunctionId;
		
		final FacebookComponent compon = getCompon();
		if(compon != null){
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					compon.getApprequestsId();
				}
			});			
		}
	}
	
	public static void deleteRequestId(final String requestId){
		final FacebookComponent compon = getCompon();
		if(compon != null){
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					compon.deleteRequestId(requestId);
				}
			});
		}
	}
	
	//java调用lua
	static void loginOnLua(final String accessToken){
		ActivityBase.getContext().runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaLoginCallbackId, accessToken);
			}
		});
	}
	
	static void getInvitableFriendsOnLua(final String friendList){
		ActivityBase.getContext().runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaGetInvitableFriendsCbId, friendList);
			}
		});
	}
	
	static void inviteOnLua(final String result){
		ActivityBase.getContext().runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaInviteCallbackId, result);
			}
		});
	}
	
	static void shareOnLua(final String result){
		ActivityBase.getContext().runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaShareCallbackId, result);
			}
		});
	}
	
	static void appRequestIdOnLua(final String result){
		ActivityBase.getContext().runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaGetRequestIdCbId, result);
			}
		});
	}
}
