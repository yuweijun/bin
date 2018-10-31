import java.lang.instrument.Instrumentation;

/**
 * <pre>
 * <plugin>
 *    <artifactId>maven-jar-plugin</artifactId>
 *    <version>2.4</version>
 *    <configuration>
 *        <archive>
 *            <manifestEntries>
 *                <Premain-class>Premain</Premain-class>
 *                <Boot-Class-Path>${user.home}/.m2/repository/org/javassist/javassist/3.21.0-GA/javassist-3.21.0-GA.jar</Boot-Class-Path>
 *                <Can-Redefine-Classes>false</Can-Redefine-Classes>
 *            </manifestEntries>
 *            <addMavenDescriptor>false</addMavenDescriptor>
 *        </archive>
 *    </configuration>
 * </plugin>
 * </pre>
 */
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
        System.setProperty("cglib.debugLocation", "target/cblib-classes");

        // Provides services that allow Java programming language agents to instrument programs running on the JVM.
        instrumentation = inst;

        // ClassFileTransformer : An agent provides an implementation of this interface in order to transform class files.
        ClassDumpTransformer classSaveTransformer = new ClassDumpTransformer();

        // Registers the supplied transformer.
        instrumentation.addTransformer(classSaveTransformer);
    }

}
