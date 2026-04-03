package com.example.document.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Webhook receiver for Prometheus Alertmanager notifications.
 *
 * Alertmanager fires POST requests to this endpoint whenever a Prometheus alert
 * transitions to FIRING or RESOLVED state.
 *
 * Endpoint: POST /actuator/alerts
 * Configured in: prometheus-values.yaml → alertmanager webhook_configs
 *
 * Alertmanager payload structure:
 * {
 *   "version": "4",
 *   "groupKey": "...",
 *   "status": "firing|resolved",
 *   "alerts": [
 *     {
 *       "status": "firing|resolved",
 *       "labels": { "alertname": "...", "severity": "...", ... },
 *       "annotations": { "summary": "...", "description": "..." },
 *       "startsAt": "ISO8601",
 *       "endsAt": "ISO8601",
 *       "fingerprint": "..."
 *     }
 *   ]
 * }
 */
@Slf4j
@RestController
@RequestMapping("/actuator/alerts")
public class AlertsController {

    /**
     * Accepts Alertmanager webhook notifications.
     * Returns 200 OK immediately so Alertmanager doesn't retry.
     * Actual processing (e.g., email, Slack) can be added here in future.
     */
    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Void> receiveAlert(@RequestBody Map<String, Object> payload) {
        String status = (String) payload.getOrDefault("status", "unknown");
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> alerts =
            (List<Map<String, Object>>) payload.getOrDefault("alerts", List.of());

        if ("firing".equals(status)) {
            for (Map<String, Object> alert : alerts) {
                @SuppressWarnings("unchecked")
                Map<String, String> labels =
                    (Map<String, String>) alert.getOrDefault("labels", Map.of());
                String alertName = labels.getOrDefault("alertname", "unknown");
                String severity   = labels.getOrDefault("severity", "none");
                String summary    = (String) alert.getOrDefault("summary", "");
                log.warn("[ALERT FIRING] severity={} alertname={} summary={}", severity, alertName, summary);
            }
        } else if ("resolved".equals(status)) {
            for (Map<String, Object> alert : alerts) {
                @SuppressWarnings("unchecked")
                Map<String, String> labels =
                    (Map<String, String>) alert.getOrDefault("labels", Map.of());
                String alertName = labels.getOrDefault("alertname", "unknown");
                log.info("[ALERT RESOLVED] alertname={}", alertName);
            }
        }

        return ResponseEntity.ok().build();
    }
}
