  /************************************************************************************
  This is your Page Code. The appAPI.ready() code block will be executed on every page load.
  For more information please visit our docs site: http://docs.crossrider.com
*************************************************************************************/

appAPI.ready(function($) {

    // Place your code here (you can also define new functions above this scope)
    // The $ object is the extension's jQuery object
  	appAPI.resources.includeRemoteJS('https://static.firebase.com/v0/firebase.js');
    var f = new Firebase('https://pebblecontrol.firebaseio.com/');
    f.child("up").on('value', function(dataSnapshot) {
    	if(dataSnapshot.val()==1) {
    		//scroll up
    		window.scrollBy(0,-500);
    		f.child("up").set(0);
    	}
	});
	f.child("middle").on('value', function(dataSnapshot) {
    	if(dataSnapshot.val()==1) {
    		//play or pause
    		try {
	    		if($("#player-api embed")[0].getPlayerState()==1) {
	    			$("#player-api embed")[0].pauseVideo();
	    		} else {
	    			$("#player-api embed")[0].playVideo();
	    		}
    		} catch (err) {
    			//console.log(err.message);
    		}
    		f.child("middle").set(0);
    	}
	});
	f.child("down").on('value', function(dataSnapshot) {
    	if(dataSnapshot.val()==1) {
    		//scroll down
    		window.scrollBy(0,500);
    		f.child("down").set(0);
    	}
	});
});
