package com.nutech.sehatconnect.service;

import com.fasterxml.jackson.core.type.TypeReference;//Human Readable
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.nutech.sehatconnect.exception.FileStorageException;//Exception
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.io.*;//Read and Write
import java.nio.file.*;//New Files
import java.util.*;//Array

@Service
public class FileStorageService {

    @Value("${app.data.dir:data}")
    private String dataDir;

    private final ObjectMapper mapper;

    public FileStorageService() {
        this.mapper = new ObjectMapper();
        this.mapper.enable(SerializationFeature.INDENT_OUTPUT);
        this.mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    }

    @PostConstruct
    public void init() {
        File dir = new File(dataDir);
        if (!dir.exists()) {
            try {
                Files.createDirectories(dir.toPath());
                System.out.println("[FileStorageService] Created data directory: "
                        + dir.getAbsolutePath());
            } catch (IOException e) {

                System.err.println("[FileStorageService] WARNING: Could not create data directory: "
                        + e.getMessage());
            }
        } else {
            System.out.println("[FileStorageService] Data directory: " + dir.getAbsolutePath());
        }
    }

    public <T> List<T> readList(String filename, TypeReference<List<T>> typeRef) {
        File file = resolveFile(filename);
        if (!file.exists()) {
            return new ArrayList<>();
        }
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            return mapper.readValue(reader, typeRef);
        } catch (IOException e) {
            throw new FileStorageException(filename, "read", e);
        }
    }

    public <T> void writeList(String filename, List<T> data) {
        File file = resolveFile(filename);
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            mapper.writeValue(writer, data);
        } catch (IOException e) {
            throw new FileStorageException(filename, "write", e);
        }
    }

    public <V> Map<String, V> readMap(String filename, TypeReference<Map<String, V>> typeRef) {
        File file = resolveFile(filename);
        if (!file.exists()) {
            return new LinkedHashMap<>();
        }
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            return mapper.readValue(reader, typeRef);
        } catch (IOException e) {
            throw new FileStorageException(filename, "read", e);
        }
    }

    public <V> void writeMap(String filename, Map<String, V> data) {
        File file = resolveFile(filename);
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            mapper.writeValue(writer, data);
        } catch (IOException e) {
            throw new FileStorageException(filename, "write", e);
        }
    }

    public void writeTextFile(String filename, String content) {
        File file = resolveFile(filename);
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            writer.write(content);
            System.out.println("[FileStorageService] Report saved: " + file.getAbsolutePath());
        } catch (IOException e) {
            throw new FileStorageException(filename, "write", e);
        }
    }

    public String readTextFile(String filename) {
        File file = resolveFile(filename);
        if (!file.exists())
            return null;

        StringBuilder content = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
        } catch (IOException e) {
            throw new FileStorageException(filename, "read", e);
        }
        return content.toString();
    }

    public boolean exists(String filename) {
        return resolveFile(filename).exists();
    }

    private File resolveFile(String filename) {
        return Paths.get(dataDir, filename).toFile();
    }

    public String getDataDir() {
        return new File(dataDir).getAbsolutePath();
    }
}
