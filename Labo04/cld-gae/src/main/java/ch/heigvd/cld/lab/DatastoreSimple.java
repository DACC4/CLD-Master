package ch.heigvd.cld.lab;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Enumeration;

@WebServlet(name = "DatastoreWrite", value = "/datastorewrite")
public class DatastoreSimple extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setContentType("text/plain");
        PrintWriter pw = resp.getWriter();

        // Determine the kind of the entity from the query parameter
        String kind = req.getParameter("_kind");
        if (kind == null || kind.isEmpty()) {
            pw.println("Error: No entity kind specified (_kind).");
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Entity entity;
        String keyName = req.getParameter("_key");
        if (keyName != null && !keyName.isEmpty()) {
            Key key = KeyFactory.createKey(kind, keyName);
            entity = new Entity(key);
        } else {
            entity = new Entity(kind);
        }

        // Process other query parameters as entity properties
        Enumeration<String> parameterNames = req.getParameterNames();
        while (parameterNames.hasMoreElements()) {
            String paramName = parameterNames.nextElement();
            if (!"_kind".equals(paramName) && !"_key".equals(paramName)) {
                String paramValue = req.getParameter(paramName);
                entity.setProperty(paramName, paramValue);
            }
        }

        // Save the entity to the Datastore
        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        datastore.put(entity);

        pw.println("Entity of type '" + kind + "' saved successfully.");
    }
}
