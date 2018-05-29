import java.lang.instrument.Instrumentation;

public class Premain {

    static Instrumentation instrumentation;

    /**
     * The agent class must implement a public static premain method similar in principle to the main application entry point.
     * After the Java Virtual Machine (JVM) has initialized,
     * each premain method will be called in the order the agents were specified,
     * then the real application main method will be called.
     **/
    public static void premain(String args, Instrumentation inst) {
        System.out.printf("%30s : %s\n", "premain in", Premain.class.getCanonicalName());

        // save cglib generated classes
        String debugLocation = System.getProperty("java.io.tmpdir") + "cblib-classes";
        System.setProperty("cglib.debugLocation", debugLocation);

        // Provides services that allow Java programming language agents to instrument programs running on the JVM.
        instrumentation = inst;

        // ClassFileTransformer : An agent provides an implementation of this interface in order to transform class files.
        ClassDumpTransformer classSaveTransformer = new ClassDumpTransformer();

        // Registers the supplied transformer.
        instrumentation.addTransformer(classSaveTransformer);
    }

}
