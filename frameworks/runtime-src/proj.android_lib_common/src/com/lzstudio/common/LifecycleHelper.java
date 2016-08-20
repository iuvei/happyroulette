package com.lzstudio.common;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public class LifecycleHelper {
	private List<ILifecycleObserver> observers = new ArrayList<ILifecycleObserver>();
	
	public void attach(ILifecycleObserver observer){
		if(!observers.contains(observer)){
			observers.add(observer);
		}
	}
	
	public void detach(ILifecycleObserver observer){
		if(!observers.contains(observer)){
			observers.remove(observer);
		}
	}
	
	public void onCreate(Activity activity, Bundle savedInstanceState){
		for(ILifecycleObserver observer : observers){
			observer.onCreate(activity, savedInstanceState);
		}
	}
	
	public void onStart(Activity activity){
		for(ILifecycleObserver observer : observers){
			observer.onStart(activity);
		}
	}
	
	public void onPause(Activity activity){
		for(ILifecycleObserver observer : observers){
			observer.onPause(activity);
		}
	}
	
	public void onResume(Activity activity){
		for(ILifecycleObserver observer : observers){
			observer.onResume(activity);
		}
	}
	
	public void onStop(Activity activity){
		for(ILifecycleObserver observer : observers){
			observer.onStop(activity);
		}		
	}
	
	public void onDestroy(Activity activity){
		for(ILifecycleObserver observer : observers){
			observer.onDestroy(activity);
		}		
	}
	
	public void onRestart(Activity activity){
		for(ILifecycleObserver observer : observers){
			observer.onRestart(activity);
		}		
	}
	
	public void onSaveInstanceState(Activity activity, Bundle outState){
		for(ILifecycleObserver observer : observers){
			observer.onSaveInstanceState(activity, outState);
		}
	}
	
	public void onRestoreInstanceState(Activity activity, Bundle savedInstanceState){
		for(ILifecycleObserver observer : observers){
			observer.onRestoreInstanceState(activity, savedInstanceState);
		}
	}
	
	public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data){
		for(ILifecycleObserver observer : observers){
			observer.onActivityResult(activity, requestCode, resultCode, data);
		}
	}	
}
