package com.happynice.googleplayservices;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.util.Log;

import com.happynice.common.ActivityBase;
import com.happynice.common.Component;

public class GoolePlayServicesJavaBridge {
	private static String TAG = GoolePlayServicesJavaBridge.class.getSimpleName();
	private static int callLuaShowAdCallbackId = -1;
	private static int callLuaIsLoadedCallbackId = -1;

	private static GoolePlayServicesComponent getCompon() {
		if (ActivityBase.getContext() != null) {
			List<Component> compons = ActivityBase.getContext().getComponentManager().findComponent(GoolePlayServicesComponent.class);
			if (compons != null && compons.size() > 0) {
				return (GoolePlayServicesComponent) compons.get(0);
			}
		}
		return null;
	}

	// lua2java 显示广告
	public static void showAd(int luaFunctionId) {
		Log.d(TAG, "showAd luaFunctionId = " + luaFunctionId);
		if (callLuaShowAdCallbackId != -1) {
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callLuaShowAdCallbackId);
			callLuaShowAdCallbackId = -1;
		}
		callLuaShowAdCallbackId = luaFunctionId;

		final GoolePlayServicesComponent compon = getCompon();
		if (compon != null) {
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				@Override
				public void run() {
					compon.showAd();
				}
			});
		}
	}

	// lua2java 判断广告是否已加载
	public static void isLoaded(int luaFunctionId) {
		Log.d(TAG, "isLoaded luaFunctionId = " + luaFunctionId);
		if (callLuaIsLoadedCallbackId != -1) {
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callLuaIsLoadedCallbackId);
			callLuaIsLoadedCallbackId = -1;
		}
		callLuaIsLoadedCallbackId = luaFunctionId;

		final GoolePlayServicesComponent compon = getCompon();
		if (compon != null) {
			ActivityBase.getContext().runOnUiThread(new Runnable() {
				@Override
				public void run() {
					if (compon.isLoaded()) {
						isLoadedOnLua("true");
					} else {
						isLoadedOnLua("false");
					}
				}
			});
		}
	}

	// java2lua
	public static void onAdClosedOnLua() {
		ActivityBase.getContext().runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaShowAdCallbackId, "");
			}
		});
	}

	// java2lua
	public static void isLoadedOnLua(final String isLoaded) {
		ActivityBase.getContext().runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callLuaIsLoadedCallbackId, isLoaded);
			}
		});
	}

}
