package com.example.document.controller;

import com.example.document.dto.DocumentDTO;
import com.example.document.service.DocumentService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(DocumentController.class)
class DocumentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private DocumentService documentService;

    @Test
    void getAllDocuments_shouldReturnOkAndJsonArray() throws Exception {
        DocumentDTO dto = new DocumentDTO(1L, "Test Doc", LocalDateTime.now(), "file.txt");
        when(documentService.getAllDocuments()).thenReturn(List.of(dto));

        mockMvc.perform(get("/api/documents"))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].name").value("Test Doc"))
                .andExpect(jsonPath("$[0].fileName").value("file.txt"));
    }

    @Test
    void uploadDocument_shouldReturnCreatedWhenValidInput() throws Exception {
        MockMultipartFile file = new MockMultipartFile(
                "file", "test.txt", "text/plain", "hello".getBytes()
        );

        DocumentDTO dto = new DocumentDTO(10L, "My File", LocalDateTime.now(), "test.txt");
        when(documentService.uploadDocument(eq("My File"), any())).thenReturn(dto);

        mockMvc.perform(multipart("/api/documents")
                        .file(file)
                        .param("name", "My File"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(10))
                .andExpect(jsonPath("$.name").value("My File"));
    }

    @Test
    void uploadDocument_shouldReturnBadRequestWhenNameBlank() throws Exception {
        MockMultipartFile file = new MockMultipartFile(
                "file", "test.txt", "text/plain", "hello".getBytes()
        );

        mockMvc.perform(multipart("/api/documents")
                        .file(file)
                        .param("name", " "))
                .andExpect(status().isBadRequest());
    }

    @Test
    void uploadDocument_shouldReturnBadRequestWhenFileEmpty() throws Exception {
        MockMultipartFile emptyFile = new MockMultipartFile(
                "file", "empty.txt", "text/plain", new byte[]{}
        );

        mockMvc.perform(multipart("/api/documents")
                        .file(emptyFile)
                        .param("name", "Name"))
                .andExpect(status().isBadRequest());
    }
}
