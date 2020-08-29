package com.example.first_app;

import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.graphics.Point;
import android.os.Build;
import android.os.CountDownTimer;
import android.os.IBinder;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;

import androidx.annotation.Nullable;

import com.example.first_app.R;

public class NoteBubbleService extends Service implements View.OnClickListener {
    public static final String TAG = "NoteBubbleService";

    private WindowManager mWindowManager;
    private View mNoteBubbleView, noteBubbleRight, noteBubbleLeft;
    private Point szWindow = new Point();

    private int x_init_cord, y_init_cord, x_init_margin, y_init_margin;

    private boolean isLeft = true;

    public NoteBubbleService() {
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        // init WindowManager
        mWindowManager = (WindowManager) getSystemService(WINDOW_SERVICE);

        getWindowManagerDefaultDisplay();

        LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);

        addNoteBubbleView(inflater);
        implementClickListeners();
        implementTouchListenerToNoteBubbleView();
    }

    private void implementClickListeners() {
        mNoteBubbleView.findViewById(R.id.close_floating_view).setOnClickListener(this);
        mNoteBubbleView.findViewById(R.id.open_activity_button).setOnClickListener(this);
    }

    private void implementTouchListenerToNoteBubbleView() {
        // Drag and move note bubble
        mNoteBubbleView.findViewById(R.id.collapse_view).setOnTouchListener(new View.OnTouchListener() {
            long time_start = 0, time_end = 0;
            private int lastAction;
            private int initX;
            private int initY;

            // Where you initially touch the screen
            private float initTouchX;
            private float initTouchY;

            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                WindowManager.LayoutParams layoutParams = (WindowManager.LayoutParams) mNoteBubbleView.getLayoutParams();
                switch (motionEvent.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        time_start = System.currentTimeMillis();

                        // Remember initial position
                        initX = layoutParams.x;
                        initY = layoutParams.y;

                        // Get touch location
                        initTouchX = motionEvent.getRawX();
                        initTouchY = motionEvent.getRawY();

                        lastAction = motionEvent.getAction();
                        return true;
                    case MotionEvent.ACTION_UP:
                        if (lastAction == MotionEvent.ACTION_DOWN) {
//                            Intent intent = new Intent(com.example.first_app.NoteBubbleService.this, )

                            // Close service
                            onNoteBubbleClick();
                        }
                        Log.d(TAG, "onTouch: initX: "+initX + ", motionEvent.getRawX(): "+motionEvent.getRawX() +", initTouchX: " + initTouchX);
                        resetPosition((int) motionEvent.getRawX());
                        return true;
                    case MotionEvent.ACTION_MOVE:
                        // Calculate X and Y coordinates of view.
                        layoutParams.x = initX + (int) (motionEvent.getRawX() - initTouchX);
                        layoutParams.y = initY + (int) (motionEvent.getRawY() - initTouchY);

                        // Update layout with new X & Y coord
                        mWindowManager.updateViewLayout(mNoteBubbleView, layoutParams);
//                        Log.d(TAG, "onTouch: layoutParmas.x: " + layoutParams.x + ", layoutParams.y: " + layoutParams.y);
                        lastAction = motionEvent.getAction();
                        return true;
                } // switch
                return false;
            }
        });
    }


    private void addNoteBubbleView(LayoutInflater inflater) {
        mNoteBubbleView = inflater.inflate(R.layout.chat_bubble, null);

        final WindowManager.LayoutParams params;

        // Initializing location of popup
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            params = new WindowManager.LayoutParams(
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                    PixelFormat.TRANSLUCENT);
        } else {
            params = new WindowManager.LayoutParams(
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.TYPE_PHONE,
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                    PixelFormat.TRANSLUCENT);
        }


        params.gravity = Gravity.TOP | Gravity.START;

        params.x = 0;
        params.y = 100;

        mWindowManager.addView(mNoteBubbleView, params);

        noteBubbleRight = mNoteBubbleView.findViewById(R.id.note_bubble_right_layout);

        noteBubbleLeft = mNoteBubbleView.findViewById(R.id.note_bubble_left_layout);
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.collapse_view:
                onNoteBubbleClick();
                break;
            case R.id.close_floating_view:
                stopSelf();
                break;
            case R.id.open_activity_button:
                // TODO: Implement
                break;
        }
    }

    private void onNoteBubbleClick() {
        if (isViewCollapsed()) {
            if (isLeft) {
                noteBubbleRight.setVisibility(View.VISIBLE);
            } else {
                noteBubbleLeft.setVisibility(View.VISIBLE);
            }
//            Log.d(TAG, "onNoteBubbleClick: " + expandedView.getVisibility() + ", " + collapsedView.getVisibility());
        } else {
            if (isLeft) {
                noteBubbleRight.setVisibility(View.GONE);
            } else {
                noteBubbleLeft.setVisibility(View.GONE);

            }
        }
    }

    /*  return status bar height on basis of device display metrics  */
    private int getStatusBarHeight() {
        return (int) Math.ceil(25 * getApplicationContext().getResources().getDisplayMetrics().density);
    }

    private boolean isViewCollapsed() {
        if (isLeft){
            return noteBubbleRight.getVisibility() == View.GONE;
        } else {
            return noteBubbleLeft.getVisibility() == View.GONE;

        }
    }

    /*  Reset position of Floating Widget view on dragging  */
    private void resetPosition(int x_cord_now) {
        Log.d(TAG, "resetPosition: x_cord_now: " + x_cord_now + ", szWindow.x: " + szWindow.x);
        if (x_cord_now <= szWindow.x / 2) {
            isLeft = true;
            moveToLeft(x_cord_now);
        } else {
            isLeft = false;
            moveToRight(x_cord_now);
        }

    }

    /*  Method to move the Floating widget view to Right  */
    private void moveToRight(final int current_x_cord) {

        new CountDownTimer(500, 5) {
            //get params of Floating Widget view
            WindowManager.LayoutParams mParams = (WindowManager.LayoutParams) mNoteBubbleView.getLayoutParams();

            public void onTick(long t) {
                long step = (500 - t) / 5;

                mParams.x = (int) (szWindow.x + (current_x_cord * current_x_cord * step) - mNoteBubbleView.getWidth());

                //If you want bounce effect uncomment below line and comment above line
//                mParams.x = szWindow.x + (int) (double) bounceValue(step, current_x_cord) - mNoteBubbleView.getWidth();

                //Update window manager for Floating Widget
                mWindowManager.updateViewLayout(mNoteBubbleView, mParams);
            }

            public void onFinish() {
                mParams.x = szWindow.x - mNoteBubbleView.getWidth();

                //Update window manager for Floating Widget
                mWindowManager.updateViewLayout(mNoteBubbleView, mParams);
            }
        }.start();

        if (noteBubbleRight.getVisibility() == View.VISIBLE){
            noteBubbleRight.setVisibility(View.GONE);
            noteBubbleLeft.setVisibility(View.VISIBLE);
        }
    }

    /*  Get Bounce value if you want to make bounce effect to your Floating Widget */
    private double bounceValue(long step, long scale) {
        double value = scale * java.lang.Math.exp(-0.1 * step) * java.lang.Math.cos(0.08 * step);
        return value;
    }


    /*  Method to move the Floating widget view to Left  */
    private void moveToLeft(final int current_x_cord) {
        final int x = szWindow.x - current_x_cord;

        new CountDownTimer(300, 5) {
            //get params of Floating Widget view
            WindowManager.LayoutParams mParams = (WindowManager.LayoutParams) mNoteBubbleView.getLayoutParams();

            public void onTick(long t) {
                long step = (300 - t) / 5;

                mParams.x = 0 - (int) (current_x_cord * current_x_cord * step);

                //If you want bounce effect uncomment below line and comment above line
//                mParams.x = 0 - (int) (double) bounceValue(step, x);


                //Update window manager for Floating Widget
                mWindowManager.updateViewLayout(mNoteBubbleView, mParams);
            }

            public void onFinish() {
                mParams.x = 0;

                //Update window manager for Floating Widget
                mWindowManager.updateViewLayout(mNoteBubbleView, mParams);
            }
        }.start();

        if (noteBubbleLeft.getVisibility() == View.VISIBLE){
            noteBubbleRight.setVisibility(View.VISIBLE);
            noteBubbleLeft.setVisibility(View.GONE);
        }
    }

    private void getWindowManagerDefaultDisplay() {
        DisplayMetrics displayMetrics = new DisplayMetrics();

        mWindowManager.getDefaultDisplay().getMetrics(displayMetrics);
        int w = displayMetrics.widthPixels;
        int h = displayMetrics.heightPixels;
        szWindow.set(w, h);
    }


    @Override
    public void onDestroy() {
        super.onDestroy();

        if (mNoteBubbleView != null) {
            mWindowManager.removeView(mNoteBubbleView);
        }
    }
}
