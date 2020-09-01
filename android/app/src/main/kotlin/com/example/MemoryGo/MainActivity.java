package com.example.MemoryGo;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.Settings;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.MemoryGo.adapters.BubbleAdapter;
import com.example.MemoryGo.model.Note;
import com.nex3z.notificationbadge.NotificationBadge;
import com.txusballesteros.bubbles.BubbleLayout;
import com.txusballesteros.bubbles.BubblesManager;
import com.txusballesteros.bubbles.OnInitializedCallback;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Timer;
import java.util.TimerTask;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.app.FlutterActivity;


public class MainActivity extends FlutterActivity {
    public static final String TAG = "MainActivity";
    public static final String CHANNEL = "com.example.MemoryGo/notebubble";
    public static final int ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST = 200;

    private BubblesManager bubblesManager;
    private BubbleLayout bubbleView;
    private RecyclerView notesRecView;
    private BubbleAdapter mAdapter;

    private View noteBubbleDrownDown;
    private TextView studySetTitleTv;
    private NotificationBadge badge;

    private ArrayList<Note> notesList, unreadNotesList;
    private String studySetTitle, durationStr, freqStr;
    private long duration, frequency;
    private int currentNoteIndex = 0;
    private boolean sessionEnded;
    private boolean bubbleRemoved;

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
                    List<Map<String, String>> notesListMap = call.argument("notesListMap");
                    studySetTitle = call.argument("studySetTitle");
                    durationStr = call.argument("duration");
                    freqStr = call.argument("frequency");
                    if (durationStr.equals("30 Mins")) {
                        duration = 1000 * 60 * 30;
                    } else if (durationStr.equals("1 Hr")) {
                        duration = 1000 * 60 * 60;
                    } else if (durationStr.equals("2 Hrs")) {
                        duration = 1000 * 60 * 120;
                    }

                    if (freqStr.equals("Very low")) {
                        frequency = duration / 5;
                    } else if (freqStr.equals("Low")) {
                        frequency = duration / 10;
                    } else if (freqStr.equals("Medium")) {
                        frequency = duration / 15;
                    } else if (freqStr.equals("High")) {
                        frequency = duration / 20;
                    }

                    initializeNotesList(notesListMap);
                    initializeBubblesManager();

                    result.success("Opening note bubble service.");
                }
            }
        });
    }

    @SuppressLint("HandlerLeak")
    public Handler timerHandler = new Handler() {
        @RequiresApi(api = Build.VERSION_CODES.O)
        @Override
        public void handleMessage(Message msg) {
            Log.d(TAG, "handleMessage: currentNoteIndex: " + currentNoteIndex);
            if (bubbleRemoved) {
                addNewBubble();
            }
            if (noteBubbleDrownDown.getVisibility() == View.GONE) {
                unreadNotesList.add(notesList.get(currentNoteIndex));

                Log.d(TAG, "handleMessage: unreadNotesList : " + unreadNotesList);
                badge.setNumber(unreadNotesList.size());
                if (currentNoteIndex == notesList.size() - 1) {
                    unreadNotesList.add(new Note("Session Ended.", ""));
                    sessionEnded = true;
                }
            } else {
                ArrayList<Note> currentNote = new ArrayList<>();
                currentNote.add(notesList.get(currentNoteIndex));
                if (currentNoteIndex == notesList.size() - 1) {
                    currentNote.add(new Note("Session Ended.", ""));
                    sessionEnded = true;
                }
                mAdapter.setNotes(currentNote);
                mAdapter.notifyDataSetChanged();
            }
            currentNoteIndex++;
        }
    };

    // Starting timer with a fixed duration and frequency
    protected void startTimer() {
        Timer timer = new Timer(false);
        timer.scheduleAtFixedRate(new TimerTask() {
            @RequiresApi(api = Build.VERSION_CODES.O)
            @Override
            public void run() {
                if (currentNoteIndex >= notesList.size()) {
                    currentNoteIndex = notesList.size() - 1;
                    timer.cancel();
                    sessionEnded = true;
                } else {
                    timerHandler.obtainMessage().sendToTarget();
                }
            }
        }, 4000, 4000);
    }

    private void initializeNotesList(List<Map<String, String>> notesListMap) {
        notesList = new ArrayList<Note>();
        unreadNotesList = new ArrayList<Note>();

        for (Map<String, String> noteMap : notesListMap) {
            notesList.add(new Note(noteMap));
        }
//        Log.d(TAG, "initializeNotesList: notesList: " + notesList);
    }

    private void initializeBubblesManager() {
        bubblesManager = new BubblesManager.Builder(this)
                .setTrashLayout(R.layout.bubble_trash_layout)
                .setInitializationCallback(new OnInitializedCallback() {
                    @RequiresApi(api = Build.VERSION_CODES.M)
                    @Override
                    public void onInitialized() {
                        if (!Settings.canDrawOverlays(MainActivity.this)) {
                            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                    Uri.parse("package:" + getPackageName()));
                            startActivityForResult(intent, ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST);
                        } else {
                            addNewBubble();
                            startTimer();
                        }
                    }
                })
                .build();
        bubblesManager.initialize();
    }

    private void addNewBubble() {
        initializeViews();
        bubbleRemoved = false;
        bubbleView.setOnBubbleRemoveListener(new BubbleLayout.OnBubbleRemoveListener() {
            @Override
            public void onBubbleRemoved(BubbleLayout bubble) {
                bubbleRemoved = true;
            }
        });
        bubbleView.setOnBubbleClickListener(new BubbleLayout.OnBubbleClickListener() {
            @RequiresApi(api = Build.VERSION_CODES.O)
            @Override
            public void onBubbleClick(BubbleLayout bubble) {
                onNoteBubbleClick();
            }
        });
        bubbleView.setShouldStickToWall(true);
        bubblesManager.addBubble(bubbleView, 60, 20);
        sessionEnded = false;
    }

    private void initializeViews() {
        bubbleView = (BubbleLayout) LayoutInflater.from(MainActivity.this).inflate(R.layout.bubble_layout, null);
        noteBubbleDrownDown = bubbleView.findViewById(R.id.note_bubble_dropdown_layout);
        studySetTitleTv = bubbleView.findViewById(R.id.study_set_title);
        studySetTitleTv.setText("Notes of " + studySetTitle);

        badge = bubbleView.findViewById(R.id.badge);
        badge.setAnimationEnabled(true);
        badge.setNumber(0);

        notesRecView = bubbleView.findViewById(R.id.notes_recycler_view);
        mAdapter = new BubbleAdapter();

        notesRecView.setAdapter(mAdapter);
        notesRecView.setLayoutManager(new LinearLayoutManager(this));
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    private void onNoteBubbleClick() {
        if (isViewCollapsed()) {
            if (unreadNotesList.size() == 0) {
                ArrayList<Note> currentNote = new ArrayList<>();
                if (sessionEnded) {
                    currentNote.add(notesList.get(notesList.size() - 1));
                    currentNote.add(new Note("Session Ended.", ""));
                } else {
                    Note note = new Note(notesList.get(currentNoteIndex).getTitle(), notesList.get(currentNoteIndex).getBody());
                    note.setTitle("Upcoming Note: " + note.getTitle());
                    currentNote.add(note);
                }
                mAdapter.setNotes(currentNote);
                mAdapter.notifyDataSetChanged();
            } else {
                mAdapter.setNotes(unreadNotesList);
                mAdapter.notifyDataSetChanged();
                unreadNotesList.clear();
                badge.setNumber(0);
            }

            noteBubbleDrownDown.setVisibility(View.VISIBLE);

        } else {
            noteBubbleDrownDown.setVisibility(View.GONE);
        }
    }

    private boolean isViewCollapsed() {
        return noteBubbleDrownDown.getVisibility() == View.GONE;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST) {
            addNewBubble();
            startTimer();

        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        bubblesManager.recycle();
    }
}