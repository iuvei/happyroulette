package com.lzstudio.googlepay;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Arrays;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.lzstudio.common.ActivityBase;
import com.lzstudio.common.Component;
import com.lzstudio.googlepay.util.IabException;
import com.lzstudio.googlepay.util.IabHelper;
import com.lzstudio.googlepay.util.IabResult;
import com.lzstudio.googlepay.util.Inventory;
import com.lzstudio.googlepay.util.Purchase;
import com.lzstudio.googlepay.util.SkuDetails;
import com.lzstudio.googlepay.util.IabHelper.OnConsumeFinishedListener;
import com.lzstudio.googlepay.util.IabHelper.OnIabSetupFinishedListener;
import com.lzstudio.googlepay.util.IabHelper.QueryInventoryFinishedListener;

public class GooglePayComponent extends Component {
	private static String TAG = GooglePayComponent.class.getSimpleName();
	
	// (arbitrary) request code for the purchase flow
	private static final int RC_REQUEST = 1001;
	
	private String base64EncodedPublicKey = "";
    // The helper object
    private IabHelper mHelper;
    
    private boolean isSetuped = false;
    private boolean isSetuping = false;
    private boolean isSupported = false;
    private boolean isLoadingGoods = false;
    private boolean isRecharging = false;
    
    private List<String> mSkuList = null;
    private Inventory mInventory = null;
    private String rechargingSku = "";
    
    private int retryTime = 3;
    
	public GooglePayComponent(String base64EncodedPublicKey){
		this.base64EncodedPublicKey = base64EncodedPublicKey;
	}

	@Override
	public void init() {
		ActivityBase.getContext().attach(this);
		onReset();
	}

	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		super.onCreate(activity, savedInstanceState);
		if(mHelper != null){
			onReset();
		}
        // Create the helper, passing it our context and the public key to verify signatures with
        Log.d(TAG, "Creating IAB helper.");
        mHelper = new IabHelper(activity, base64EncodedPublicKey);

        // enable debug logging (for a production application, you should set this to false).
        mHelper.enableDebugLogging(true);		
	}

	@Override
	public void onDestroy(Activity activity) {
		super.onDestroy(activity);
		onReset();
	}

	@Override
	public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        Log.d(TAG, "onActivityResult(" + requestCode + "," + resultCode + "," + data);
        if (mHelper == null) return;

        // Pass on the activity result to the helper for handling
        if (!mHelper.handleActivityResult(requestCode, resultCode, data)) {
            // not handled, so handle it ourselves (here's where you'd
            // perform any handling of activity results not related to in-app
            // billing...
            super.onActivityResult(activity, requestCode, resultCode, data);
        }
        else {
            Log.d(TAG, "onActivityResult handled by IABUtil.");
        }
	}
	
	//启动
	void startSetup(){
		Log.d(TAG, "startSetup");
		if(mHelper != null){
			if(!isSetuped){
				if(!isSetuping){
					Log.d(TAG, "startSetup 1");
					
					isSetuping = true;
					retryTime = 3;
					mHelper.startSetup(onIabSetupFinishedListener);
				}
			}else{
				Log.d(TAG, "startSetup 2");
				GooglePayJavaBridge.setupOnLua(String.valueOf(isSupported));
			}
		}else{
			Log.d(TAG, "startSetup 3");
			onReset();
			mHelper = new IabHelper(ActivityBase.getContext(), base64EncodedPublicKey);
			mHelper.enableDebugLogging(true);
			retryTime = 3;
			mHelper.startSetup(onIabSetupFinishedListener);
		}
	}
	
	private OnIabSetupFinishedListener onIabSetupFinishedListener = new OnIabSetupFinishedListener() {
		
		@Override
		public void onIabSetupFinished(IabResult result) {
            Log.d(TAG, "Setup finished." + result);

            if (!result.isSuccess()) {
            	Log.d(TAG, "Setup finished. 1");
                if(retryTime-- > 0){
                	mHelper.startSetup(onIabSetupFinishedListener);
                }else{
                	isSetuped = true;
                	isSetuping = false;
                	isSupported = false;
                	GooglePayJavaBridge.setupOnLua(String.valueOf(isSupported));
                }
            }else{
            	Log.d(TAG, "Setup finished 2.");
            	isSetuped = true;
            	isSetuping = false;
            	isSupported = true;
            	GooglePayJavaBridge.setupOnLua(String.valueOf(isSupported));
            }		
		}
	};
	
	//查询
	void loadingGoods(String goods){
		Log.d(TAG, "loading goods:" + goods);
		if(mHelper != null && isSupported && isSetuped && !isLoadingGoods){
			isLoadingGoods = true;
			String[] skus = goods.split(",");
			mSkuList = Arrays.asList(skus);
			mHelper.queryInventoryAsync(true, mSkuList, mGotInventoryListener);
		}
	}
	
    // Listener that's called when we finish querying the items and subscriptions we own
    private QueryInventoryFinishedListener mGotInventoryListener = new QueryInventoryFinishedListener() {
        public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
            Log.d(TAG, "Query inventory finished. result:" + result);

            // Have we been disposed of in the meantime? If so, quit.
            if (mHelper == null) return;

            if (result.isFailure()) {
            	if(retryTime-- > 0){
            		mHelper.queryInventoryAsync(true, mSkuList, mGotInventoryListener);
            	}else{
            		isLoadingGoods = false;
            		GooglePayJavaBridge.loadGoodsOnLua("failed");
            	}
            }else{
            	Log.d(TAG, "Query inventory was successful.");
            	isLoadingGoods = false;
            	mInventory = inventory;
            	
            	JSONArray skuDetailsJson = new JSONArray();
            	if(mSkuList != null){
            		for(String sku : mSkuList){
            			//检查是否买了商品，没有消费掉
            			Purchase purchase = inventory.getPurchase(sku);
            			if(purchase != null){
            				JSONObject jsonObj = new JSONObject();
            				try {
            					Log.d(TAG, "Query inventory already own sku:" + purchase.getSku());
            					jsonObj.put("sku", purchase.getSku());
								jsonObj.put("originalJson", purchase.getOriginalJson());
								jsonObj.put("signature", URLEncoder.encode(purchase.getSignature(), "UTF-8"));
							} catch (JSONException e) {
								e.printStackTrace();
							} catch (UnsupportedEncodingException e) {
								e.printStackTrace();
							}
            				GooglePayJavaBridge.deliveryOnLua(jsonObj.toString());
            			}
            			
            			//遍历商品信息
            			SkuDetails skuDetails = inventory.getSkuDetails(sku);
            			if(skuDetails != null){
            				JSONObject jsonObj = new JSONObject();
            				try {
								jsonObj.put("sku", skuDetails.getSku());
								jsonObj.put("priceSymbol", skuDetails.getPrice());
								jsonObj.put("price", skuDetails.getPriceData());
								jsonObj.put("symbol", skuDetails.getSymbol());
							} catch (JSONException e) {
								e.printStackTrace();
							}
            				skuDetailsJson.put(jsonObj);
            			}
            		}
            	}
            	
            	GooglePayJavaBridge.loadGoodsOnLua(skuDetailsJson.toString());
            }
            Log.d(TAG, "Initial inventory query finished; enabling main UI.");
        }
    };	
    
    //消费商品
    void consume(String sku){
    	Log.d(TAG, "consume");
    	if(mHelper != null && isSetuped && isSupported){
    		Purchase skuPurchase = null;
    		if(mInventory == null){
    			try {
					mInventory = mHelper.queryInventory(true, mSkuList);
					skuPurchase = mInventory.getPurchase(sku);
				} catch (IabException e) {
					e.printStackTrace();
				}
    		}else{
    			skuPurchase = mInventory.getPurchase(sku);
    		}
    		
    		if(skuPurchase != null){
    			Log.d(TAG, "consume 2");
    			mHelper.consumeAsync(skuPurchase, mConsumeFinishedListener);
    		}
    	}
    }
    
    // Called when consumption is complete
    private OnConsumeFinishedListener mConsumeFinishedListener = new OnConsumeFinishedListener() {
        public void onConsumeFinished(Purchase purchase, IabResult result) {
            Log.d(TAG, "Consumption finished. Purchase: " + purchase + ", result: " + result);

            // if we were disposed of in the meantime, quit.
            if (mHelper == null) return;

            if (result.isSuccess()) {
                // successfully consumed, so we apply the effects of the item in our
                // game world's logic
                Log.d(TAG, "Consumption successful. Provisioning.");
                mInventory.erasePurchase(purchase.getSku());
                GooglePayJavaBridge.consumeOnLua(purchase.getSku());
            }else {
            	Log.d(TAG, "Consumption failure. Provisioning.");
            	GooglePayJavaBridge.consumeOnLua("failed");
            }
            Log.d(TAG, "End consumption flow.");
        }
    };    
    
    //购买商品
    void recharge(String skuData){
    	Log.d(TAG, "recharge isRecharging:" + isRecharging);
    	try {
			if(mHelper != null && isSupported && isSetuped && !isRecharging){
				JSONObject skuDataJson = new JSONObject(skuData);
				String sku = skuDataJson.optString("sku");
				rechargingSku = sku;
				Log.d(TAG, "recharge rechargingSku 1 :" + isRecharging);
				
				String payload = skuDataJson.optString("uid");
				isRecharging = true;
				mHelper.launchPurchaseFlow(ActivityBase.getContext(), sku, RC_REQUEST, mPurchaseFinishedListener, payload);
				Log.d(TAG, "recharge rechargingSku 2 :" + isRecharging);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
    }
    
    // Callback for when a purchase is finished
    IabHelper.OnIabPurchaseFinishedListener mPurchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
        public void onIabPurchaseFinished(IabResult result, Purchase purchase) {
            Log.d(TAG, "Purchase finished: " + result + ", purchase: " + purchase + ",respon:" + result.getResponse());
            isRecharging = false;
            // if we were disposed of in the meantime, quit.
            if (mHelper == null) return;
            
            if(purchase != null && mInventory != null){
            	mInventory.addPurchase(purchase);
            }

            if (result.isFailure()) {
            	if(purchase == null && mInventory != null){//已经购买了，没有消费，purchase == null
            		purchase = mInventory.getPurchase(rechargingSku);
            	}
            	Log.d(TAG, "Purchase finished: " + result + ",sku purchase: " + purchase);
            	if(result.getResponse() == IabHelper.BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED && purchase != null){
            		JSONObject jsonObj = new JSONObject();
            		try {
						jsonObj.put("sku", purchase.getSku());
						jsonObj.put("originalJson", purchase.getOriginalJson());
						jsonObj.put("signature", URLEncoder.encode(purchase.getSignature(), "UTF-8"));
						GooglePayJavaBridge.rechargeOnLua(jsonObj.toString());
					} catch (JSONException e) {
						e.printStackTrace();
					} catch (UnsupportedEncodingException e) {
						e.printStackTrace();
					}
            	}else if(result.getResponse() == IabHelper.IABHELPER_USER_CANCELLED){
            		GooglePayJavaBridge.rechargeOnLua("canceled");
            	}else{
            		GooglePayJavaBridge.rechargeOnLua("failed");
            	}
            }else{
            	Log.d(TAG, "Purchase successful.");
        		JSONObject jsonObj = new JSONObject();
        		try {
					jsonObj.put("sku", purchase.getSku());
					jsonObj.put("originalJson", purchase.getOriginalJson());
					jsonObj.put("signature", URLEncoder.encode(purchase.getSignature(), "UTF-8"));
					GooglePayJavaBridge.rechargeOnLua(jsonObj.toString());
				} catch (JSONException e) {
					e.printStackTrace();
				} catch (UnsupportedEncodingException e) {
					e.printStackTrace();
				}            	
            }
        }
    };   
    
    //dipose
    void dipose(){
    	Log.d(TAG, "dispose");
    	onReset();
    }
	
	boolean isSetuped(){
		return this.isSetuped;
	}
	
	boolean isSupported(){
		return this.isSupported;
	}

	private void onReset(){
        // very important:
        Log.d(TAG, "Destroying helper.");
        if (mHelper != null) {
            mHelper.dispose();
            mHelper = null;
        }		
        
        isSetuped = false;
        isSetuping = false;
        isSupported = false;
        isLoadingGoods = false;
	}
}
