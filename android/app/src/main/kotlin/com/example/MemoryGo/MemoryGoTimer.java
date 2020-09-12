package com.example.MemoryGo;

import java.util.Timer;

public class MemoryGoTimer extends Timer {
    public MemoryGoTimer(boolean isDaemon) {
        super(isDaemon);
    }

    private long startTime = 0;

    public void start() {
        startTime = System.currentTimeMillis();
    }

    public long getElapsedTime() {
        return System.currentTimeMillis() - startTime; // In milliseconds
    }

}
