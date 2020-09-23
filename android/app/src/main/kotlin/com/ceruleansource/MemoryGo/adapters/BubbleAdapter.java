package com.example.MemoryGo.adapters;

import android.graphics.Color;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.MemoryGo.R;
import com.example.MemoryGo.model.Note;

import java.util.ArrayList;

public class BubbleAdapter extends RecyclerView.Adapter<BubbleAdapter.NoteViewHolder> {

    public static final String TAG = "BubbleAdapter";

    private ArrayList<Note> notes = new ArrayList<>();

    public BubbleAdapter() {
    }

    @NonNull
    @Override
    public NoteViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.note_list_item, parent, false);
        NoteViewHolder noteViewHolder = new NoteViewHolder(view);
        return noteViewHolder;
    }

    @Override
    public void onBindViewHolder(@NonNull NoteViewHolder holder, int position) {
        holder.noteTitleTv.setText(notes.get(position).getTitle());
        holder.noteBodyTv.setText(notes.get(position).getBody());

        if (holder.noteTitleTv.getText().equals("Session Ended.")){
            holder.noteTitleTv.setTextColor(Color.RED);
        }
    }

    @Override
    public int getItemCount() {
        return notes.size();
    }

    public void setNotes(ArrayList<Note> notes) {
        this.notes.clear();
        this.notes.addAll(notes);
    }

    public void addNote(Note note){
        this.notes.add(note);
        this.notifyDataSetChanged();
    }

    public ArrayList<Note> getNotes() {
        return notes;
    }

    public static class NoteViewHolder extends RecyclerView.ViewHolder {

        private TextView noteTitleTv, noteBodyTv;

        public NoteViewHolder(@NonNull View itemView) {
            super(itemView);
            noteTitleTv = itemView.findViewById(R.id.note_title);
            noteBodyTv = itemView.findViewById(R.id.note_body);
        }
    }

}
