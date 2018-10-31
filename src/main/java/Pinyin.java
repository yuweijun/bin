import com.ibm.icu.text.Transliterator;

import java.util.stream.Stream;

/**
 * ICU = International Components for Unicode
 *
 * @author yuweijun
 * @since 2018-10-31
 */
public final class Pinyin {

    public static void main(String[] args) {
        if (args.length == 0) {
            System.out.println("Usage: pinyin 中文文字");
            System.exit(1);
        }

        Transliterator pinyin = Transliterator.getInstance("Han-Latin/Names; Latin-Ascii; Any-Upper");
        Stream.of(args).forEach(arg -> {
            String transform = pinyin.transform(arg);
            System.out.println(transform);
        });
    }

}
