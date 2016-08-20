package com.happynice.googleplayservices;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.InterstitialAd;
import com.happynice.common.ActivityBase;
import com.happynice.common.Component;

public class GoolePlayServicesComponent extends Component {
	static InterstitialAd mInterstitialAd;
	String mAdId;

	public GoolePlayServicesComponent(String adId) {
		mAdId = adId;
	}

	@Override
	public void init() {
		ActivityBase.getContext().attach(this);
	}

	@Override
	public void setName(String name) {
		// TODO Auto-generated method stub
		super.setName(name);
	}

	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		super.onCreate(activity, savedInstanceState);

		// 构造广告对象
		mInterstitialAd = new InterstitialAd(activity);

		// 设置广告ID
		mInterstitialAd.setAdUnitId(mAdId);
		// 请求加载新的广告
		requestNewInterstitial();
		// 设置事件监听
		mInterstitialAd.setAdListener(new AdListener() {
			@Override
			public void onAdClosed() {
				requestNewInterstitial();
				GoolePlayServicesJavaBridge.onAdClosedOnLua();
			}

			@Override
			public void onAdLoaded() {
				// TODO Auto-generated method stub
				super.onAdLoaded();
			}

			@Override
			public void onAdFailedToLoad(int errorCode) {
				// TODO Auto-generated method stub
				super.onAdFailedToLoad(errorCode);
			}

			@Override
			public void onAdLeftApplication() {
				// TODO Auto-generated method stub
				super.onAdLeftApplication();
			}

			@Override
			public void onAdOpened() {
				// TODO Auto-generated method stub
				super.onAdOpened();
			}

		});
	}

	@Override
	public void onStart(Activity activity) {
		// TODO Auto-generated method stub
		super.onStart(activity);
	}

	@Override
	public void onPause(Activity activity) {
		// TODO Auto-generated method stub
		super.onPause(activity);
	}

	@Override
	public void onResume(Activity activity) {
		// TODO Auto-generated method stub
		super.onResume(activity);
	}

	@Override
	public void onStop(Activity activity) {
		// TODO Auto-generated method stub
		super.onStop(activity);
	}

	@Override
	public void onDestroy(Activity activity) {
		// TODO Auto-generated method stub
		super.onDestroy(activity);
	}

	@Override
	public void onRestart(Activity activity) {
		// TODO Auto-generated method stub
		super.onRestart(activity);
	}

	@Override
	public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(activity, requestCode, resultCode, data);
	}

	private static void requestNewInterstitial() {
		AdRequest adRequest = new AdRequest.Builder()
		// .addTestDevice("BE6A6DFD387A4E26096CC6A71E9C1C73")
				.build();

		mInterstitialAd.loadAd(adRequest);
	}

	public void showAd() {
		if (mInterstitialAd.isLoaded()) {
			mInterstitialAd.show();
		} else {
			requestNewInterstitial();
		}
	}

	public boolean isLoaded() {
		return mInterstitialAd.isLoaded();
	}
}
