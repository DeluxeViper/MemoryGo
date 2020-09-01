package com.example.first_app;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.example.MemoryGo.NoteBubbleService;
import com.google.android.material.snackbar.Snackbar;

import java.util.Objects;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.app.FlutterActivity;


public class MainActivity extends FlutterActivity {
    public static final String CHANNEL = "com.example.MemoryGo/notebubble";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        new MethodChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @RequiresApi(api = Build.VERSION_CODES.M)
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                if (call.method.equals("openNoteBubble")) {

                    if (Settings.canDrawOverlays(MainActivity.this)) {
                        Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:" + getPackageName()));
                        startActivityForResult(intent, 0);
                    }
                    result.success("Opening note bubble service.");
                }
            }
        });
    }

    private void startNoteBubbleService() {
        startService(new Intent(MainActivity.this, NoteBubbleService.class));
        finish();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == 0) {
            startNoteBubbleService();
        } else {
            Snackbar.make(findViewById(android.R.id.content), "Error. Please enable Draw Overlay Permissions in Settings for popup to work.", Snackbar.LENGTH_LONG).show();
        }
    }
}