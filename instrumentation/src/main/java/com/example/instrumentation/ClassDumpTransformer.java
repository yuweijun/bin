package com.example.instrumentation;

import javassist.ClassPool;
import javassist.CtClass;

import java.io.File;
import java.io.IOException;
import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.ProtectionDomain;

/**
 * 因为agent依赖javassist，在build时需要加入<Boot-Class-Path>
 * <p>
 * Created by yuweijun on 2017-08-17.
 */
public class ClassDumpTransformer implements ClassFileTransformer {

    @Override
    public byte[] transform(ClassLoader loader, String className, Class<?> classBeingRedefined,
                            ProtectionDomain protectionDomain, byte[] classfileBuffer) throws IllegalClassFormatException {
        byte[] transformed = null;
        ClassPool pool;
        CtClass cl = null;
        try {
            if (className != null && !className.startsWith("java")) {
                pool = ClassPool.getDefault();
                cl = pool.makeClass(new java.io.ByteArrayInputStream(classfileBuffer));

                if (cl.isInterface() == false) {
                    transformed = cl.toBytecode();

                    saveClass(cl, transformed);
                }
            }
        } catch (Exception e) {
            System.err.println("Could not instrument " + className + ",  exception : " + e.getMessage());
        } finally {
            if (cl != null) {
                cl.detach();
            }
        }

        return transformed;
    }

    private void saveClass(CtClass cl, byte[] transformed) {
        try {
            String name = cl.getName();
            if (name.startsWith("com.example")
                    || name.startsWith("com.sun.proxy")
                    || name.startsWith("sun.reflect")) {
                String fileName = "target/generated-classes/" + name.replaceAll("\\.", "/") + ".class";
                Path path = Paths.get(fileName);
                Path parent = path.getParent();
                String dir = parent.toString();

                if (!parent.toFile().exists()) {
                    System.out.printf("%30s : %s\n", "directory", dir);
                    System.out.printf("%30s : %s\n", "create directory", dir);
                    new File(dir).mkdirs();
                }

                if (!path.toFile().exists()) {
                    System.out.printf("%30s : %s\n", "class file", fileName);
                    Path file = Files.createFile(path);
                    Files.write(file, transformed);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}
