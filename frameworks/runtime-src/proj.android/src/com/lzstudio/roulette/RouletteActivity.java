package com.lzstudio.roulette;

import android.os.Bundle;

//import com.happynice.bmob.BmobComponent;
import com.lzstudio.common.ActivityBase;
import com.lzstudio.common.ComponentName;
import com.lzstudio.googlepay.GooglePayComponent;
import com.lzstudio.roulette.R;


public class RouletteActivity extends ActivityBase{
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		createShortcut(R.string.app_name, R.drawable.icon);
//		QuickHTTPInterface.initHttpsURLConnection();
	}

	@Override
	protected void setComponents() {
//		componManager.addComponent(ComponentName.BMOB,new BmobComponent());
//		componManager.addComponent(ComponentName.FACEBOOK,new FacebookComponent());
		String base64EncodedPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAm4PP2ywCUIknneH5ALltjrPzXvNxL0GeUbXRpLNcjXNCRpN9T+Eu8x+JQRi1++MlBg1phoiMIOU2ZVWfyE4PnDmkhc0JoPL/79+HudWvhQA6cPKPrBIP0+klx60HuhOCVZkAp2hSyyS5uP/Gu/SDBWhX7nEGQGecA8l7VeWLpuT0Is2iI1gYTtGaKC2ExxfVmplJoTV4KCLwhIjDHxW8tz8N6WqB0+ObiWVMrQeeZSr3p4NN00ONPKjAZCJegpzkndfh529aLuX0+Ci4gtVAtJAKKkam2/8HWuTqWj8ipxJSvLjbhG8xv/ogCwsjFZcZ813cU1zEQDGNX+iTg2zHswIDAQAB";
		componManager.addComponent(ComponentName.GOOGLE_PAY, new GooglePayComponent(base64EncodedPublicKey));
//		componManager.addComponent(ComponentName.XINGE, new XingeComponent());
//		Set<String> merchantIdSet = new HashSet<String>();
//		merchantIdSet.add("4101");
//		merchantIdSet.add("4102");
//		String secretKey = "5d038461cbd15f582c13ce99f06f9104";
//		componManager.addComponent(ComponentName.EASY2PAY, new Easy2PayComponent(merchantIdSet, secretKey));
//		componManager.addComponent(ComponentName.GOOGLEPLAYSERVICES, new GoolePlayServicesComponent("ca-app-pub-2197528622766653/3395933125"));//视频
	}

}
