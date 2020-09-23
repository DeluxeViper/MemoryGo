package com.example.MemoryGo;

import java.util.Timer;

public class MemoryGoTimer extends Timer {

    private boolean isRunning;

    public MemoryGoTimer(boolean isDaemon) {
        super(isDaemon);
    }

    private long startTime = 0;

    public void start() {
        isRunning = true;
        startTime = System.currentTimeMillis();
    }

    public long getElapsedTime() {
        return System.currentTimeMillis() - startTime; // In milliseconds
    }

    @Override
    public void cancel() {
        isRunning = false;
        super.cancel();
    }

    public boolean isRunning() {
        return isRunning;
    }

    public void setRunning(boolean running) {
        isRunning = running;
    }
}
