package com.example.document.service;

import com.example.document.dto.DocumentDTO;
import com.example.document.dto.DocumentUpdateRequest;
import com.example.document.entity.Document;
import com.example.document.repository.DocumentRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.mockito.ArgumentCaptor;
import org.springframework.core.io.Resource;
import org.springframework.mock.web.MockMultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class DocumentServiceTest {

    private DocumentRepository documentRepository;
    private DocumentService documentService;

    @TempDir
    Path tempDir;

    @BeforeEach
    void setUp() {
        documentRepository = mock(DocumentRepository.class);
        documentService = new DocumentService(documentRepository, tempDir.toString());
    }

    @Test
    void uploadDocument_shouldStoreFileAndReturnDto() throws IOException {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "sample.txt",
                "text/plain",
                "hello world".getBytes()
        );

        when(documentRepository.save(any(Document.class))).thenAnswer(invocation -> {
            Document d = invocation.getArgument(0);
            d.setId(1L);
            return d;
        });

        DocumentDTO result = documentService.uploadDocument("My Doc", file);

        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("My Doc", result.getName());
        assertEquals("sample.txt", result.getFileName());

        verify(documentRepository).save(any(Document.class));

        // file should be persisted in upload dir
        assertTrue(Files.list(tempDir).findAny().isPresent());
    }

    @Test
    void getAllDocuments_shouldMapEntityToDto() {
        Document doc = new Document();
        doc.setId(1L);
        doc.setName("Doc 1");
        doc.setUploadTime(LocalDateTime.now());
        doc.setFileName("uuid_sample.pdf");

        when(documentRepository.findAll()).thenReturn(List.of(doc));

        List<DocumentDTO> result = documentService.getAllDocuments();

        assertEquals(1, result.size());
        assertEquals("Doc 1", result.get(0).getName());
        assertEquals("sample.pdf", result.get(0).getFileName());
    }

    @Test
    void updateDocument_shouldUpdateNameAndFile() {
        Document existing = new Document();
        existing.setId(1L);
        existing.setName("Old Name");
        existing.setUploadTime(LocalDateTime.now());
        existing.setFileName("old_old.txt");

        when(documentRepository.findById(1L)).thenReturn(Optional.of(existing));
        when(documentRepository.save(any(Document.class))).thenAnswer(invocation -> invocation.getArgument(0));

        MockMultipartFile newFile = new MockMultipartFile(
                "file",
                "new.txt",
                "text/plain",
                "new-content".getBytes()
        );
        DocumentUpdateRequest request = new DocumentUpdateRequest();
        request.setName("New Name");

        DocumentDTO result = documentService.updateDocument(1L, request, newFile);

        assertEquals("New Name", result.getName());
        assertEquals("new.txt", result.getFileName());

        ArgumentCaptor<Document> captor = ArgumentCaptor.forClass(Document.class);
        verify(documentRepository).save(captor.capture());
        assertEquals("New Name", captor.getValue().getName());
    }

    @Test
    void downloadFile_shouldReturnResourceWhenFileExists() throws IOException {
        Path filePath = tempDir.resolve("uuid_test.txt");
        Files.writeString(filePath, "data");

        Document doc = new Document();
        doc.setId(1L);
        doc.setFileName("uuid_test.txt");

        when(documentRepository.findById(1L)).thenReturn(Optional.of(doc));

        Resource resource = documentService.downloadFile(1L);

        assertTrue(resource.exists());
        assertTrue(resource.isReadable());
    }

    @Test
    void deleteDocument_shouldDeleteFileAndEntity() throws IOException {
        Path filePath = tempDir.resolve("uuid_delete.txt");
        Files.writeString(filePath, "delete me");

        Document doc = new Document();
        doc.setId(2L);
        doc.setFileName("uuid_delete.txt");

        when(documentRepository.findById(2L)).thenReturn(Optional.of(doc));

        documentService.deleteDocument(2L);

        verify(documentRepository).delete(doc);
        assertFalse(Files.exists(filePath));
    }
}
