package com.nooralhidayah.noor_al_hidayah;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

/**
 * شاشة تشخيص الانهيار — تعمل في عملية منفصلة (:crash) حتى لا تُغلق مع التطبيق.
 * بدون Flutter وبدون ملفات تصميم: واجهتها تُبنى بالكود.
 */
public class CrashActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String extra = getIntent() != null ? getIntent().getStringExtra("text") : null;
        final String text = (extra == null || extra.isEmpty()) ? "(لا يوجد سجل)" : extra;

        float d = getResources().getDisplayMetrics().density;
        int pad = (int) (16 * d);

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(Color.parseColor("#0B3D2E"));
        root.setPadding(pad, pad * 2, pad, pad);

        TextView title = new TextView(this);
        title.setText("سجل الانهيار — صوّر هذه الشاشة وأرسلها للمطوّر");
        title.setTextColor(Color.parseColor("#D4AF37"));
        title.setTextSize(16);
        root.addView(title, new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT));

        ScrollView scroll = new ScrollView(this);
        TextView body = new TextView(this);
        body.setText(text);
        body.setTextColor(Color.parseColor("#F3EFE0"));
        body.setTextSize(11);
        body.setTextIsSelectable(true);
        body.setPadding(0, pad, 0, pad);
        scroll.addView(body);
        root.addView(scroll, new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));

        Button copy = new Button(this);
        copy.setText("نسخ السجل");
        copy.setOnClickListener(new android.view.View.OnClickListener() {
            @Override
            public void onClick(android.view.View v) {
                try {
                    ClipboardManager cm =
                            (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
                    cm.setPrimaryClip(ClipData.newPlainText("crash", text));
                    Toast.makeText(CrashActivity.this, "تم النسخ", Toast.LENGTH_SHORT).show();
                } catch (Throwable ignored) {
                }
            }
        });
        root.addView(copy, new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT));

        Button close = new Button(this);
        close.setText("إغلاق");
        close.setOnClickListener(new android.view.View.OnClickListener() {
            @Override
            public void onClick(android.view.View v) {
                finish();
            }
        });
        root.addView(close, new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT));

        setContentView(root);
    }
}
