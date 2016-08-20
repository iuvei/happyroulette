package com.lzstudio.common;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public interface ILifecycleObserver {
	void onCreate(Activity activity, Bundle savedInstanceState);
	void onStart(Activity activity);
	void onPause(Activity activity);
	void onResume(Activity activity);
	void onStop(Activity activity);
	void onDestroy(Activity activity);
	void onRestart(Activity activity);
	void onSaveInstanceState(Activity activity, Bundle outState);
	void onRestoreInstanceState(Activity activity, Bundle savedInstanceState);	
	void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data);	
}
