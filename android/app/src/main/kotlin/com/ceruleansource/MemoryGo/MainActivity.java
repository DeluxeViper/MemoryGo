package com.example.MemoryGo;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.provider.Settings;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.MemoryGo.adapters.BubbleAdapter;
import com.example.MemoryGo.model.Note;
import com.google.android.material.button.MaterialButton;
import com.nex3z.notificationbadge.NotificationBadge;
import com.txusballesteros.bubbles.BubbleLayout;
import com.txusballesteros.bubbles.BubblesManager;
import com.txusballesteros.bubbles.OnInitializedCallback;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Random;
import java.util.TimerTask;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
// import io.flutter.app.FlutterActivity;


public class MainActivity extends FlutterActivity {
    public static final String TAG = "MainActivity";
    public static final String CHANNEL = "com.example.MemoryGo/notebubble";
    public static final int ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST = 200;

    private BubblesManager bubblesManager;
    private BubbleLayout bubbleView;
    private RecyclerView notesRecView;
    private MaterialButton stopButton;
    private BubbleAdapter mAdapter;

    private View noteBubbleDrownDown;
    private TextView studySetTitleTv;
    private NotificationBadge badge;

    private ArrayList<Note> notesList, unreadNotesList, shuffleReadList = new ArrayList<>();
    private String studySetTitle, durationStr, freqStr;
    private long duration, frequency;
    private int currentNoteIndex = 0, previousNoteIndex = 0;
    private boolean sessionEnded, repeat, bubbleRemoved, overwrite, shuffle;
    private MethodChannel.Result methodResult;
    private MemoryGoTimer timer;
    private Random rand = new Random();


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        sessionEnded = false;
        timer = new MemoryGoTimer(false);

        super.onCreate(savedInstanceState);
        new MethodChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @RequiresApi(api = Build.VERSION_CODES.M)
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                if (call.method.equals("openNoteBubble")) {
                    // If statement purpose: If session has ended and bubble has not been removed, then you can start another cycle by pressing go.
                    // Also: If session has ended and bubble has been removed, then you can start another cycle by pressing go.
                    if (sessionEnded && !bubbleRemoved) {
                        bubblesManager.recycle();
                        sessionEnded = false;
                    } else if (!sessionEnded && timer.isRunning() && !bubbleRemoved) {
                        // To make sure that when you press go and session is not ended, that it doesn't let allow it to go through.
                        Toast.makeText(getContext(), "Session is already running", Toast.LENGTH_SHORT).show();
                        return;
                    } else if (!sessionEnded && timer.isRunning() && bubbleRemoved){
                        if (!studySetTitle.equals(call.argument("studySetTitle"))){
                            // If bubble is opened from a different study set, let user know
                            Toast.makeText(getContext(), "Session is already running from different Study Set", Toast.LENGTH_LONG).show();
                        }
                        addNewBubble();
                        return;
                    }

                    methodResult = result;

                    // Initializing variables
                    List<Map<String, String>> notesListMap = call.argument("notesListMap");
                    studySetTitle = call.argument("studySetTitle");
                    durationStr = call.argument("duration");
                    freqStr = call.argument("frequency");

                    String repeatStr = call.argument("repeat");
                    if (repeatStr.toLowerCase().equals("false")) {
                        repeat = false;
                    } else if (repeatStr.toLowerCase().equals("true")) {
                        repeat = true;
                    } else {
                        throw new Error("Error. Unrecognizable Setting parameter: Repeat");
                    }

                    String overwriteStr = call.argument("overwrite");
                    if (overwriteStr.toLowerCase().equals("false")) {
                        overwrite = false;
                    } else if (overwriteStr.toLowerCase().equals("true")) {
                        overwrite = true;
                    } else {
                        throw new Error("Error. Unrecognizable Setting parameter: Overwrite");
                    }

                    String shuffleStr = call.argument("shuffle");
                    if (shuffleStr.toLowerCase().equals("false")) {
                        shuffle = false;
                    } else if (shuffleStr.toLowerCase().equals("true")) {
                        shuffle = true;
                    } else {
                        throw new Error("Error. Unrecognizable Setting parameter: Shuffle.");
                    }

                    if (durationStr.equals("15 Mins")){
                        duration = 1000 * 60 * 15;
                    }
                    else if (durationStr.equals("30 Mins")) {
                        duration = 1000 * 60 * 30;
                    } else if (durationStr.equals("1 Hr")) {
                        duration = 1000 * 60 * 60;
                    } else if (durationStr.equals("2 Hrs")) {
                        duration = 1000 * 60 * 120;
                    } else {
                        throw new Error("Error. Unrecognizable Setting parameter: Duration");
                    }

                    if (freqStr.equals("Very low")) {
                        frequency = duration / 5;
                    } else if (freqStr.equals("Low")) {
                        frequency = duration / 10;
                    } else if (freqStr.equals("Medium")) {
                        frequency = duration / 15;
                    } else if (freqStr.equals("High")) {
                        frequency = duration / 20;
                    } else {
                        throw new Error("Error. Unrecognizable Setting parameter: Frequency");
                    }

                    Log.d(TAG, "onMethodCall: notesList: " + notesListMap);
                    initializeNotesList(notesListMap);
                    initializeBubblesManager();
                }
            }
        });
    }

    // This system needs double checking
    @SuppressLint("HandlerLeak")
    public Handler timerHandler = new Handler() {
        @RequiresApi(api = Build.VERSION_CODES.O)
        @Override
        public void handleMessage(Message msg) {
            Log.d(TAG, "handleMessage: currentNoteIndex: " + currentNoteIndex);
            if (bubbleRemoved) {
                addNewBubble();
            }

            // If repeat is true then let the timer keep going until duration is reached
            if (repeat) {
                if (!shuffle) {
                    // If shuffle is false and repeat is false
                    if (currentNoteIndex >= notesList.size()) {
                        currentNoteIndex = 0;
                    }
                } else {
                    // Shuffle is true and repeat is true
                    // Do nothing -> Will keep cycling through notes until duration has ended
                    previousNoteIndex = currentNoteIndex;
                }
            } else {
                // Repeat is false and shuffle is true -> Shuffle through cards, (does not go through the same card more than once) and ends when all notes are read
                if (shuffle) {
                    previousNoteIndex = currentNoteIndex;
                    shuffleReadList.add(notesList.get(currentNoteIndex));
                    if (shuffleReadList.containsAll(notesList)) {
//                        Log.d(TAG, "handleMessage: stopping session because all of the notes are read.");
                        stopSession();
                        return;
                    }
                }
                // TODO: Implement logic is repeat is false and shuffle is false
            }
            // Overwrite logic needs double checking
            if (noteBubbleDrownDown.getVisibility() == View.GONE && overwrite) {
                if (!unreadNotesList.contains(notesList.get(currentNoteIndex))) {
                    unreadNotesList.add(notesList.get(currentNoteIndex));
                }
//                Log.d(TAG, "handleMessage: unreadNotesList : " + unreadNotesList);

                badge.setNumber(unreadNotesList.size());
                if (currentNoteIndex == notesList.size() - 1 && !repeat && !shuffle) {
//                    Log.d(TAG, "handleMessage: stopping session because last note is read and repeat is off. (overwrite is on)");
                    stopSession();
                }
            } else {
                if (noteBubbleDrownDown.getVisibility() == View.GONE) {
                    if (badge.getTextView().toString().equals("1")) {
                        badge.setNumber(0);
                        badge.setNumber(1);
                    } else {
                        badge.setNumber(1);
                    }
                }
                ArrayList<Note> currentNote = new ArrayList<>();
                currentNote.add(notesList.get(currentNoteIndex));
                if (currentNoteIndex == notesList.size() - 1 && !repeat && !shuffle) {
//                    Log.d(TAG, "handleMessage: stopping session because last note is read and repeat is off. (overwrite is off)");
                    stopSession();
                }
                mAdapter.setNotes(currentNote);
                mAdapter.notifyDataSetChanged();
            }

            if (!shuffle) {
                currentNoteIndex++;
            } else {
                if (!repeat) {
                    int noteIndex;
                    // If repeat is off and shuffle is on, then you cant go through the same note
                    do {
                        noteIndex = rand.nextInt(notesList.size());
                    } while (shuffleReadList.contains(notesList.get(noteIndex)) && noteIndex != currentNoteIndex);
                    currentNoteIndex = noteIndex;
                } else {
                    // Repeat is on and shuffle is on, then it runs for forever
                    int noteIndex;
                    do {
                        noteIndex = rand.nextInt(notesList.size());
                    } while (noteIndex == currentNoteIndex);
                    currentNoteIndex = noteIndex;
                }
            }
        }
    };

    // Starting timer with a fixed duration and frequency
    protected void startTimer() {
        rand = new Random();
        shuffleReadList.clear();
//        Log.d(TAG, "startTimer: starting timer");
        addNewBubble();
        timer = new MemoryGoTimer(false);
        timer.start();

        // Testing purposes
        // duration = 20000;
        // frequency = 4000;

        timer.scheduleAtFixedRate(new TimerTask() {
            @RequiresApi(api = Build.VERSION_CODES.O)
            @Override
            public void run() {
                // If repeat is off
                if (!repeat) {
                    if (currentNoteIndex >= notesList.size() || timer.getElapsedTime() >= duration) {
//                        Log.d(TAG, "run: stopping session because last note has been reached OR duration has been met. (repeat is off)");
                        stopSession();
                    } else {
                        timerHandler.obtainMessage().sendToTarget();
                    }
                } else {
                    // Repeat is on
                    if (timer.getElapsedTime() >= duration) {
//                        Log.d(TAG, "run: stopping session because duration has been met. (repeat is on)");
                        stopSession();
                    } else {
                        timerHandler.obtainMessage().sendToTarget();
                    }
                }

            }
        }, 0, frequency);
    }

    public void stopSession() {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @RequiresApi(api = Build.VERSION_CODES.O)
            @Override
            public void run() {
                if (mAdapter.getNotes().size() == 0) {
                    mAdapter.addNote(new Note("Session Ended.", ""));
                } else if (!mAdapter.getNotes().get(mAdapter.getNotes().size() - 1).getTitle().equals("Session Ended.")) {
                    // Checking if the last note in adapter contains session ended, if it doesn't then add session ended
                    mAdapter.addNote(new Note("Session Ended.", ""));
                }
                sessionEnded = true;
                timer.cancel();
//                Log.d(TAG, "run: Posted Success.");
                stopButton.setVisibility(View.GONE);
                methodResult.success("Session Success");
            }
        });
    }

    private void initializeNotesList(List<Map<String, String>> notesListMap) {
        notesList = new ArrayList<Note>();
        unreadNotesList = new ArrayList<Note>();

        for (Map<String, String> noteMap : notesListMap) {
            notesList.add(new Note(noteMap));
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    private void initializeBubblesManager() {
        currentNoteIndex = 0;
        if (!Settings.canDrawOverlays(MainActivity.this)) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:" + getPackageName()));
            startActivityForResult(intent, ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST);
        } else {
            bubblesManager = new BubblesManager.Builder(this)
                    .setTrashLayout(R.layout.bubble_trash_layout)
                    .setInitializationCallback(new OnInitializedCallback() {
                        @RequiresApi(api = Build.VERSION_CODES.M)
                        @Override
                        public void onInitialized() {
                            startTimer();
                        }
                    })
                    .build();
            bubblesManager.initialize();
        }

    }

    private void addNewBubble() {
        initializeViews();
        bubbleRemoved = false;
        bubbleView.setOnBubbleRemoveListener(new BubbleLayout.OnBubbleRemoveListener() {
            @Override
            public void onBubbleRemoved(BubbleLayout bubble) {
                bubbleRemoved = true;
                if (sessionEnded) {
                    bubblesManager.recycle();
                }
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
        bubblesManager.addBubble(bubbleView, 20, 20);
        sessionEnded = false;
    }

    private void initializeViews() {
        bubbleView = (BubbleLayout) LayoutInflater.from(MainActivity.this).inflate(R.layout.bubble_layout, null);
        stopButton = bubbleView.findViewById(R.id.stopButton);
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

        stopButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                stopSession();
            }
        });
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    private void onNoteBubbleClick() {
        if (isViewCollapsed()) {
            if (unreadNotesList.size() == 0) {
                badge.setNumber(0); // This might seem redundant, but it is for if overwrite is false and the one notification that gets added
                ArrayList<Note> currentNote = new ArrayList<>();
                if (sessionEnded) {
                    if (!shuffle) {
                        // This if statement is due to the currentNoteIndex++ in the timer that causes the noteindex to be 1 more than it is
                        if (currentNoteIndex >= 1) {
                            currentNote.add(notesList.get(currentNoteIndex - 1));
                        } else {
                            // If currentNoteIndex = 0, then let it stay at 0
                            currentNote.add(notesList.get(currentNoteIndex));
                        }
                    } else {
                        currentNote.add(notesList.get(previousNoteIndex));
                    }

                    currentNote.add(new Note("Session Ended.", ""));
                } else {
                    // This if statement is due to the currentNoteIndex++ in the timer that causes the noteindex to be 1 more than it is
                    if (!shuffle) {
                        if (currentNoteIndex >= 1) {
                            currentNote.add(notesList.get(currentNoteIndex - 1));
                        } else {
                            currentNote.add(notesList.get(currentNoteIndex));
                        }
                    } else {
                        currentNote.add(notesList.get(previousNoteIndex));
                    }
//                    Note note = new Note(notesList.get(currentNoteIndex).getTitle(), notesList.get(currentNoteIndex).getBody());
//                    note.setTitle("Upcoming Note: " + note.getTitle());
//                    currentNote.add(note);
                }
                mAdapter.setNotes(currentNote);
                mAdapter.notifyDataSetChanged();
            } else {
                mAdapter.setNotes(unreadNotesList);
                mAdapter.notifyDataSetChanged();

                if (sessionEnded) {
                    mAdapter.addNote(new Note("Session Ended.", ""));
                } else {
                    unreadNotesList.clear();
                }
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

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST) {
            if (!Settings.canDrawOverlays(this)) {
                Toast.makeText(getContext(), "Permission not granted.", Toast.LENGTH_SHORT).show();
            } else {
                bubblesManager = new BubblesManager.Builder(this)
                        .setTrashLayout(R.layout.bubble_trash_layout)
                        .setInitializationCallback(new OnInitializedCallback() {
                            @RequiresApi(api = Build.VERSION_CODES.M)
                            @Override
                            public void onInitialized() {
                                startTimer();
                            }
                        })
                        .build();
                bubblesManager.initialize();
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        bubblesManager.recycle();
    }
}