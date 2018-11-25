package com.example.instrumentation;

import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.Instrumentation;

public class Premain {

    static Instrumentation instrumentation;

    public static void premain(String args, Instrumentation inst) {
        instrumentation = inst;
        ClassDumpTransformer classSaveTransformer = new ClassDumpTransformer();
        instrumentation.addTransformer(classSaveTransformer);
    }

}
