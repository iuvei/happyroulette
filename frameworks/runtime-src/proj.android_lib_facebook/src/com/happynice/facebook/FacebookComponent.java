package com.happynice.facebook;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.pm.Signature;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;

import com.facebook.AppEventsLogger;
import com.facebook.FacebookAuthorizationException;
import com.facebook.FacebookException;
import com.facebook.FacebookOperationCanceledException;
import com.facebook.HttpMethod;
import com.facebook.Request;
import com.facebook.Request.Callback;
import com.facebook.Response;
import com.facebook.Session;
import com.facebook.Session.NewPermissionsRequest;
import com.facebook.Session.OpenRequest;
import com.facebook.SessionDefaultAudience;
import com.facebook.SessionState;
import com.facebook.UiLifecycleHelper;
import com.facebook.android.R;
import com.facebook.widget.FacebookDialog;
import com.facebook.widget.WebDialog;
import com.facebook.widget.WebDialog.OnCompleteListener;
import com.happynice.common.ActivityBase;
import com.happynice.common.Component;

public class FacebookComponent extends Component {
	private static final String TAG = FacebookComponent.class.getSimpleName();
    private static final List<String> PERMISSIONS = new ArrayList<String>() {
		private static final long serialVersionUID = 1L;
		{
            add("user_friends");
            add("public_profile");
            add("email");
        }
    };
	
    private enum PendingAction {
        NONE,
        LOGIN,
        INVITE,
        SHARE,
        GET_INVITABLE_FRIENDS,
        GET_APPREQUESTS_ID,
    }
    
	private final String PENDING_ACTION_BUNDLE_KEY = "com.happynice.facebook:PendingAction";
	private PendingAction pendingAction = PendingAction.NONE;
	private UiLifecycleHelper uiHelper;
	
	//自动feed需要
	private static final String ADDITIONAL_PERMISSIONS = "publish_actions";
    private boolean pendingPublish = true;
    private boolean shouldImplicitlyPublish = true;
    
    private Session.StatusCallback newPermissionsCallback = new Session.StatusCallback() {
        @Override
        public void call(Session session, SessionState state, Exception exception) {
            if (exception != null ||
                    !session.isOpened() ||
                    !session.getPermissions().contains(ADDITIONAL_PERMISSIONS)) {
                // this means the user did not grant us write permissions, so
                // we don't do implicit publishes
                shouldImplicitlyPublish = false;
                pendingPublish = false;
                
                //不论授权成不成功都给他登录
                FacebookJavaBridge.loginOnLua(Session.getActiveSession().getAccessToken());
            } else {
                publishResult();
            }
        }
    };
    
    private DialogInterface.OnClickListener canPublishClickListener = new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialogInterface, int i) {
            final Session session = Session.getActiveSession();
            if (session != null && session.isOpened()) {
                // if they choose to publish, then we request for publish permissions
                shouldImplicitlyPublish = true;
                pendingPublish = true;
                Session.NewPermissionsRequest newPermissionsRequest =
                        new Session.NewPermissionsRequest(ActivityBase.getContext(), ADDITIONAL_PERMISSIONS)
                                .setDefaultAudience(SessionDefaultAudience.FRIENDS)
                                .setCallback(newPermissionsCallback);
                session.requestNewPublishPermissions(newPermissionsRequest);
            }
        }
    };

    private DialogInterface.OnClickListener dontPublishClickListener = new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialogInterface, int i) {
            // if they choose not to publish, then we save that choice, and don't prompt them
            // until they restart the app
            pendingPublish = false;
            shouldImplicitlyPublish = false;
        }
    };
    
    private boolean canPublish() {
        final Session session = Session.getActiveSession();
        if (session != null && session.isOpened()) {
            if (session.getPermissions().contains(ADDITIONAL_PERMISSIONS)) {
                // if we already have publish permissions, then go ahead and publish
                return true;
            } else {
                // otherwise we ask the user if they'd like to publish to facebook
                new AlertDialog.Builder(ActivityBase.getContext())
                        .setTitle(R.string.share_with_friends_title)
                        .setMessage(R.string.share_with_friends_message)
                        .setPositiveButton(R.string.share_with_friends_yes, canPublishClickListener)
                        .setNegativeButton(R.string.share_with_friends_no, dontPublishClickListener)
                        .show();
                return false;
            }
        }
        return false;
    }
    
    private void publishResult() {
        if (shouldImplicitlyPublish && canPublish()) {
        	FacebookJavaBridge.loginOnLua(Session.getActiveSession().getAccessToken());        	
        }
    }    
	
    private Session.StatusCallback statusCallback = new Session.StatusCallback() {
        @Override
        public void call(Session session, SessionState state, Exception exception) {
            onSessionStateChange(session, state, exception);
        }
    };
    
    private FacebookDialog.Callback facebookDialogCallback = new FacebookDialog.Callback() {
        @Override
        public void onError(FacebookDialog.PendingCall pendingCall, Exception error, Bundle data) {
            Log.d(TAG, String.format("facebookDialogCallback Error: %s", error.toString()));
        }

        @Override
        public void onComplete(FacebookDialog.PendingCall pendingCall, Bundle data) {
            Log.d(TAG, "facebookDialogCallback Success!");
        }
    };

	@Override
	public void init() {
		ActivityBase.getContext().attach(this);
	}

	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		super.onCreate(activity, savedInstanceState);
        uiHelper = new UiLifecycleHelper(activity, statusCallback);
        uiHelper.onCreate(savedInstanceState);
	    try {
	        PackageInfo info = activity.getPackageManager().getPackageInfo(
	        		activity.getPackageName(), 
	                PackageManager.GET_SIGNATURES);
	        Log.d(TAG, "apk name:" + activity.getPackageName());
	        for (Signature signature : info.signatures) {
	            MessageDigest md = MessageDigest.getInstance("SHA");
	            md.update(signature.toByteArray());
	            Log.d(TAG, Base64.encodeToString(md.digest(), Base64.DEFAULT));
	            }
	    } catch (NameNotFoundException e) {
	    	e.printStackTrace();
	    } catch (NoSuchAlgorithmException e) {
	    	e.printStackTrace();
	    }
        if (savedInstanceState != null) {
            String name = savedInstanceState.getString(PENDING_ACTION_BUNDLE_KEY);
            pendingAction = PendingAction.valueOf(name);
        }		
	}

	@Override
	public void onPause(Activity activity) {
		super.onPause(activity);
		uiHelper.onPause();
        // Call the 'deactivateApp' method to log an app event for use in analytics and advertising
        // reporting.  Do so in the onPause methods of the primary Activities that an app may be launched into.
        AppEventsLogger.deactivateApp(activity);		
	}

	@Override
	public void onResume(Activity activity) {
		super.onResume(activity);
		uiHelper.onResume();
        // Call the 'activateApp' method to log an app event for use in analytics and advertising reporting.  Do so in
        // the onResume methods of the primary Activities that an app may be launched into.
        AppEventsLogger.activateApp(activity);
	}

	@Override
	public void onDestroy(Activity activity) {
		super.onDestroy(activity);
		uiHelper.onDestroy();
	}

	@Override
	public void onSaveInstanceState(Activity activity, Bundle outState) {
		super.onSaveInstanceState(activity, outState);
		uiHelper.onSaveInstanceState(outState);
		outState.putString(PENDING_ACTION_BUNDLE_KEY, pendingAction.name());
	}

	@Override
	public void onActivityResult(Activity activity, int requestCode,
			int resultCode, Intent data) {
		super.onActivityResult(activity, requestCode, resultCode, data);
		uiHelper.onActivityResult(requestCode, resultCode, data, facebookDialogCallback);
	}
	
    private boolean sessionHasNecessaryPerms(Session session){
        if (session != null && session.getPermissions() != null) {
            for (String requestedPerm : PERMISSIONS) {
                if (!session.getPermissions().contains(requestedPerm)) {
                    return false;
                }
            }
            return true;
        }
        return false;
    }
	
	private void onSessionStateChange(Session session, SessionState state, Exception exception){
		Log.d(TAG, "onSessionStateChange session:" + session + " state:" + state.name() + ", exception:" + exception);
        if (pendingAction != PendingAction.NONE && (exception instanceof FacebookOperationCanceledException ||
                exception instanceof FacebookAuthorizationException)) {
            handlePendingAction(exception instanceof FacebookOperationCanceledException ? "canceled" : "failed");
        }else if(state == SessionState.OPENED_TOKEN_UPDATED || state == SessionState.OPENED ||
        	state == SessionState.CREATED_TOKEN_LOADED){
            if(sessionHasNecessaryPerms(session)){
            	handlePendingAction("success");
            }else{
            	requestReadPermission(session);
            }
        }
	}
	
	private void requestReadPermission(Session session){
		if(session.isOpened()){
			Log.d(TAG, "opened:" + session.toString());
			session.requestNewReadPermissions(new NewPermissionsRequest(ActivityBase.getContext(), PERMISSIONS).setCallback(statusCallback));
		}else{
			Log.d(TAG, session.toString());
			if(session.isClosed()){
				session.removeCallback(statusCallback);
				session.closeAndClearTokenInformation();
				session = new Session(ActivityBase.getContext());
				session.addCallback(statusCallback);
				Session.setActiveSession(session);
			}			
			session.openForRead(new OpenRequest(ActivityBase.getContext()).setPermissions(PERMISSIONS).setCallback(statusCallback));
		}		
	}
	
    private void handlePendingAction(String result){
    	Log.d(TAG, "handlePendingAction result:" + result);
        PendingAction previouslyPendingAction = pendingAction;
        // These actions may re-set pendingAction if they are still pending, but we assume they
        // will succeed.
        pendingAction = PendingAction.NONE;

        switch (previouslyPendingAction) {
            case LOGIN:
            	onLogin(result);
                break;
            case INVITE:
            	onInvite(result);
                break;
            case SHARE:
            	onShare(result);
            	break;
            case GET_INVITABLE_FRIENDS:
            	onInvitableFriends(result);
            	break;
            case GET_APPREQUESTS_ID:
            	onAppRequestsId(result);
            	break;
        	case NONE:            	
        	default:
        		break;            	
        }
    }

    //登录
	void login(){
		try{
			pendingAction = PendingAction.NONE;
			Session session = Session.getActiveSession();
			if(session == null){
				session = new Session(ActivityBase.getContext());				
				session.addCallback(statusCallback);
				Session.setActiveSession(session);
			}else if(session.isOpened()){
				Date expireData = session.getExpirationDate();
				if(null != expireData && expireData.compareTo(new Date()) > 0){
					FacebookJavaBridge.loginOnLua(session.getAccessToken());
					return;
				}
			}else if(session.isClosed()){
				session.removeCallback(statusCallback);
				session.closeAndClearTokenInformation();
				session = new Session(ActivityBase.getContext());
				session.addCallback(statusCallback);
				Session.setActiveSession(session);
			}
			
			pendingAction = PendingAction.LOGIN;
			if(session.getState() != SessionState.OPENING){
				if(session.isOpened()){
					session.requestNewReadPermissions(new NewPermissionsRequest(ActivityBase.getContext(), PERMISSIONS).setCallback(statusCallback));
				}else{
					session.openForRead(new OpenRequest(ActivityBase.getContext()).setPermissions(PERMISSIONS).setCallback(statusCallback));
				}
			}
		}catch(Exception e){
			pendingAction = PendingAction.NONE;
			e.printStackTrace();
		}
	}
	
	private void onLogin(String result){
		if(result.equals("success")){
//			if(pendingPublish){
//				publishResult();
//			}
			FacebookJavaBridge.loginOnLua(Session.getActiveSession().getAccessToken());
		}else{
			FacebookJavaBridge.loginOnLua(result);
		}
	}
	
	//登出
	void logout(){
		Session session = Session.getActiveSession();
		if(session != null){
			pendingAction = PendingAction.NONE;
			session.removeCallback(statusCallback);
			session.closeAndClearTokenInformation();
		}
	}
	
	//邀请好友
	void getInvitableFriends(){
		Session session = Session.getActiveSession();
		if(session != null){
			pendingAction = PendingAction.GET_INVITABLE_FRIENDS;
			if(sessionHasNecessaryPerms(session)){
				handlePendingAction("success");
			}else{
				requestReadPermission(session);
			}
		}
	}
	
	private void onInvitableFriends(String result){
		if(result.equals("success")){
			Log.d(TAG, "onInvitableFriends begin");
			Request req =  Request.newGraphPathRequest(Session.getActiveSession(), "me/invitable_friends", new Callback() { 
				
				@Override
				public void onCompleted(Response response) {
					Log.d(TAG, "onInvitableFriends end");
					if(response.getError() != null){
						Log.e(TAG, "onInvitableFriends error:" + response.getError().toString());
						FacebookJavaBridge.getInvitableFriendsOnLua("failed");
					}else{
						String ret = response.getRawResponse();
						Log.d(TAG, "onInvitableFriends ret:" + ret);
						
						try {
							JSONObject retObj = new JSONObject(ret);
							JSONArray rawFriendList = retObj.getJSONArray("data");
							
							JSONArray friendList = new JSONArray();
							int len = rawFriendList.length();
							Log.d(TAG, "onInvitableFriends len:" + len);
							
							for(int index = 0; index < len; index++){
								JSONObject friend = rawFriendList.getJSONObject(index);
								JSONObject obj = new JSONObject();
								obj.put("id", friend.optString("id"));
								obj.put("name", friend.optString("name"));
								JSONObject picture = friend.getJSONObject("picture");
								if(picture != null){
									JSONObject data = picture.getJSONObject("data");
									if(data != null){
										obj.put("url", data.optString("url"));
									}
								}
								
								friendList.put(obj);
							}
							
							FacebookJavaBridge.getInvitableFriendsOnLua(friendList.toString());
						} catch (JSONException e) {
							FacebookJavaBridge.getInvitableFriendsOnLua("failed");
							e.printStackTrace();
						}
					}
				}
			});
			Bundle b = new Bundle();
			b.putInt("limit", 1000);
			req.setParameters(b);
			req.executeAsync();
		}else{
			FacebookJavaBridge.getInvitableFriendsOnLua(result);
		}
	}
	
	//发送邀请
	private String inviteData;
	void invite(String inviteData){
		this.inviteData = inviteData;
		Session session = Session.getActiveSession();
		if(session != null){
			pendingAction = PendingAction.INVITE;
			if(sessionHasNecessaryPerms(session)){
				handlePendingAction("success");
			}else{
				requestReadPermission(session);
			}			
		}
	}
	
	private void onInvite(String result){
		if(result.equals("success")){
			try {
				JSONObject inviteJsonObj = new JSONObject(inviteData);
				Bundle parameters = new Bundle();
				parameters.putString("title", inviteJsonObj.optString("title"));
				parameters.putString("message", inviteJsonObj.optString("message"));
				parameters.putString("to", inviteJsonObj.optString("toIds"));
				parameters.putString("data", inviteJsonObj.optString("data"));
				
				WebDialog apprequestsDialog = new WebDialog.Builder(ActivityBase.getContext(), Session.getActiveSession(), "apprequests", parameters)
					.setOnCompleteListener(new OnCompleteListener() {
						
						@Override
						public void onComplete(Bundle values, FacebookException error) {
							if(error != null){
								if(error instanceof FacebookOperationCanceledException){
									FacebookJavaBridge.inviteOnLua("canceled");
								}else{
									FacebookJavaBridge.inviteOnLua("failed");
								}
							}else if(values != null){
								String requestId = values.getString("request");
								if(requestId != null){
									Iterator<String> iter = values.keySet().iterator();
									Pattern p = Pattern.compile("^to\\[(\\d+)\\]$");
									
									StringBuilder idsSb = new StringBuilder();
									while(iter.hasNext()) {
										String key = iter.next();
										if(p.matcher(key).matches()) {
											if(idsSb.length() > 0) {
												idsSb.append(",");
											}
											idsSb.append(values.getString(key));
										}
									}
									JSONObject json = new JSONObject();
									try {
										json.put("requestId", requestId);
										json.put("toIds", idsSb.toString());
									} catch(Exception e) {
										Log.e(TAG, e.getMessage(), e);
									}
									FacebookJavaBridge.inviteOnLua(json.toString());									
								}else{
									FacebookJavaBridge.inviteOnLua("canceled");
								}
							}
						}
					}).build();
				
				apprequestsDialog.show();
			} catch (JSONException e) {
				FacebookJavaBridge.inviteOnLua("failed");
				e.printStackTrace();
			}
			
		}else{
			FacebookJavaBridge.inviteOnLua(result);
		}
	}
	
	//发送分享
	private String shareData;
	void share(String shareData){
		this.shareData = shareData;
		Session session = Session.getActiveSession();
		if(session != null){
			pendingAction = PendingAction.SHARE;
			if(sessionHasNecessaryPerms(session)){
				handlePendingAction("success");
			}else{
				requestReadPermission(session);
			}			
		}		
	}
	
	private void onShare(String result){
		if(result.equals("success")){
			try {
				JSONObject shareJsonObj = new JSONObject(shareData);
				Bundle parameters = new Bundle();
				parameters.putString("name", shareJsonObj.optString("name"));
				parameters.putString("caption", shareJsonObj.optString("caption"));
				parameters.putString("picture", shareJsonObj.optString("picture"));
				parameters.putString("link", shareJsonObj.optString("link"));
				
				WebDialog shareDialog = new WebDialog.Builder(ActivityBase.getContext(), Session.getActiveSession(), "feed", parameters)
					.setOnCompleteListener(new OnCompleteListener() {
						
						@Override
						public void onComplete(Bundle values, FacebookException error) {
							if(error != null){
								if(error instanceof FacebookOperationCanceledException){
									FacebookJavaBridge.shareOnLua("canceled");
								}else{
									FacebookJavaBridge.shareOnLua("failed");
								}								
							}else if(values != null){
								String postId = values.getString("post_id");
								if(postId != null){
									FacebookJavaBridge.shareOnLua(postId);
								}else{
									FacebookJavaBridge.shareOnLua("canceled");
								}
							}
						}
					}).build();
				
				shareDialog.show();
			} catch (JSONException e) {
				FacebookJavaBridge.shareOnLua("failed");
				e.printStackTrace();
			}
			
		}else{
			FacebookJavaBridge.shareOnLua(result);
		}
	}
	
	//获取用户apprequests
	void getApprequestsId(){
		Session session = Session.getActiveSession();
		if(session != null){
			pendingAction = PendingAction.GET_APPREQUESTS_ID;
			if(sessionHasNecessaryPerms(session)){
				handlePendingAction("success");
			}else{
				requestReadPermission(session);
			}			
		}			
	}
	
	private void onAppRequestsId(String result){
		if(result.equals("success")){
			new Request(Session.getActiveSession(), "me/apprequests", null, HttpMethod.GET, new Callback() {
				
				@Override
				public void onCompleted(Response response) {
					if(response.getError() != null){
						Log.e(TAG, "onAppRequestsId error:" + response.getError().toString());
						FacebookJavaBridge.appRequestIdOnLua("failed");
					}else{
						String ret = response.getRawResponse();
						Log.d(TAG, "onAppRequestsId ret:" + ret);
						
						try {
							JSONObject retJsonObj = new JSONObject(ret);
							JSONArray dataJsonObj = retJsonObj.getJSONArray("data");
							
							if(dataJsonObj != null && dataJsonObj.length() > 0){
								JSONObject resultJsonObj = new JSONObject();
								JSONObject appRequestIdObj = dataJsonObj.getJSONObject(0);//最近的一个请求
								
								resultJsonObj.put("requestId", appRequestIdObj.opt("id"));
								resultJsonObj.put("requestData", appRequestIdObj.opt("data"));
								
								FacebookJavaBridge.appRequestIdOnLua(resultJsonObj.toString());
							}else{
								FacebookJavaBridge.appRequestIdOnLua("failed");
							}
						} catch (JSONException e) {
							FacebookJavaBridge.appRequestIdOnLua("failed");
							e.printStackTrace();
						}
					}
				}
			}).executeAsync();
		}else{
			FacebookJavaBridge.appRequestIdOnLua("failed"); 
		}
	}
	
	//删除requestId
	public void deleteRequestId(String requestId){
		Log.d(TAG, "deleteRequestId requestId:" + requestId);
		new Request(Session.getActiveSession(), requestId, null, HttpMethod.DELETE, new Callback() {
			
			@Override
			public void onCompleted(Response response) {
				if(response.getError() != null){
					Log.e(TAG, "deleteRequestId error:" + response.getError().toString());
				}else{
					String ret = response.getRawResponse();
					Log.d(TAG, "deleteRequestId ret:" + ret);
				}
			}
		}).executeAsync();
	}
}
