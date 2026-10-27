import java.io.File;
import java.lang.reflect.Method;
import java.util.ArrayList;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/** Reads private JNLP arguments in-process so console tokens are not in argv. */
public final class JnlpLauncher {
    public static void main(String[] args) throws Exception {
        if (args.length != 1) throw new IllegalArgumentException("Expected private JNLP path");
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        factory.setFeature("http://xml.org/sax/features/external-general-entities", false);
        factory.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
        factory.setXIncludeAware(false);
        factory.setExpandEntityReferences(false);
        Document document = factory.newDocumentBuilder().parse(new File(args[0]));
        NodeList descriptors = document.getElementsByTagName("application-desc");
        if (descriptors.getLength() != 1) throw new IllegalArgumentException("Expected one application-desc");
        Element descriptor = (Element) descriptors.item(0);
        String mainClass = descriptor.getAttribute("main-class");
        if (!"com.avocent.drac5.kvm.Main".equals(mainClass)) {
            throw new IllegalArgumentException("Unexpected viewer class");
        }
        NodeList nodes = descriptor.getElementsByTagName("argument");
        ArrayList<String> arguments = new ArrayList<String>();
        for (int i = 0; i < nodes.getLength(); i++) arguments.add(nodes.item(i).getTextContent());
        Method main = Class.forName(mainClass).getMethod("main", String[].class);
        // Do not print exceptions from the proprietary viewer: they may include tokens.
        try {
            main.invoke(null, (Object) arguments.toArray(new String[arguments.size()]));
        } catch (java.lang.reflect.InvocationTargetException exception) {
            System.err.println("Viewer failed. Inspect architecture, JNLP freshness and OOB connectivity privately.");
            System.exit(1);
        }
    }
}

