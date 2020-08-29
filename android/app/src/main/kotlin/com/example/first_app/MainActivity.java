package com.example.first_app;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.example.first_app.NoteBubbleService;

import java.util.Objects;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.app.FlutterActivity;


public class MainActivity extends FlutterActivity {
    public static final String CHANNEL = "com.example.first_app/notebubble";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        new MethodChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                if (call.method.equals("openNoteBubble")) {
                    startNoteBubbleService();
                    result.success("Opening note bubble service.");
                }
            }
        });
    }

    private void startNoteBubbleService() {
        startService(new Intent(MainActivity.this, NoteBubbleService.class));
        finish();
    }
}