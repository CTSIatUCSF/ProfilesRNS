/**
 * ClinicalTrials
 * --------------
 * Renders the Clinical Trials plugin into the table:
 *   .researcherprofiles--researcher-profile-page--clinical-trials--table
 *
 * Output structure (per trial):
 *   <tr>
 *     <td class="...--main-section">
 *       <a href="..." target="_blank">TITLE</a>
 *       <div class="...--conditions">Conditions: A; B; C</div>
 *     </td>
 *     <td class="...--meta-section">
 *       <div>Timeline: Mon YYYY → Mon YYYY (est.)</div>
 *       <div>Status: ...</div>
 *     </td>
 *   </tr>
 *
 * Notes:
 * - Uses DOM APIs (.textContent/.href) so text is inserted safely (no HTML escaping needed).
 * - Normalizes Conditions from comma-separated (often with no spaces) to semicolon-separated.
 * - Timeline uses CompletionDate if present; else EstimatedCompletionDate with " (est.)".
 */

window.ClinicalTrials = window.ClinicalTrials || {};

/**
 * Entry point called by the page:
 *   ClinicalTrials.init('[{...}, {...}]');
 */
ClinicalTrials.init = function (plugindata) {
    // plugindata is a JSON string. Parse it into an array of trial objects.
    $(document).ready(function () {
        ClinicalTrials.render(JSON.parse(plugindata));
    });
};

/**
 * Render all trial rows into the target table.
 */
ClinicalTrials.render = function (trials) {
    // Guard: do nothing if missing / empty data
    if (!Array.isArray(trials) || !trials.length) return;

    // Find the target table in the DOM
    var table = document.querySelector(
        '.researcherprofiles--researcher-profile-page--clinical-trials--table'
    );
    if (!table) return;

    // Ensure a <tbody> exists (your shell HTML may omit it)
    var tbody = table.querySelector('tbody');
    if (!tbody) {
        tbody = document.createElement('tbody');
        table.appendChild(tbody);
    }

    // Append a row for each trial
    trials.forEach(function (trial) {
        tbody.appendChild(ClinicalTrials.buildRow(trial));
    });
};

/**
 * Build a single <tr> for one trial.
 */
ClinicalTrials.buildRow = function (t) {
    // Create row and its two columns
    var tr = document.createElement('tr');

    var main = document.createElement('td');
    main.className = 'researcherprofiles--researcher-profile-page--clinical-trials--main-section';

    var meta = document.createElement('td');
    meta.className = 'researcherprofiles--researcher-profile-page--clinical-trials--meta-section';

    // ---- Main column: Title link + Conditions ----

    // Title link (most prominent)
    var link = document.createElement('a');
    link.href = t.SourceUrl || '#';
    link.target = '_blank';
    link.textContent = t.Title || '';
    main.appendChild(link);

    // Conditions line (comma-separated input -> semicolon-separated output)
    var conditions = document.createElement('div');
    conditions.className = 'researcherprofiles--researcher-profile-page--clinical-trials--conditions';
    conditions.textContent = 'Conditions: ' + ClinicalTrials.conditionsText(t.Conditions);
    main.appendChild(conditions);

    // ---- Meta column: Timeline + Status ----

    // Timeline line
    var timeline = document.createElement('div');
    timeline.textContent = ClinicalTrials.timelineText(t);
    meta.appendChild(timeline);

    // Status line
    var status = document.createElement('div');
    status.textContent = 'Status: ' + (t.Status || '');
    meta.appendChild(status);

    // Assemble row
    tr.appendChild(main);
    tr.appendChild(meta);

    return tr;
};

/**
 * Convert an ISO timestamp to "Mon YYYY" (e.g., "2024-07-24..." -> "Jul 2024").
 */
ClinicalTrials.monthYear = function (iso) {
    if (!iso) return '';
    return new Date(iso).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short'
    });
};

/**
 * Build the timeline string:
 * - Always includes StartDate month/year
 * - Adds arrow + end date:
 *    - CompletionDate if present
 *    - else EstimatedCompletionDate + " (est.)"
 *
 * Examples:
 * - "Jul 2024 → Apr 2027 (est.)"
 * - "Mar 2020 → Apr 2022"
 * - "Jul 2015" (if no end dates at all)
 */
ClinicalTrials.timelineText = function (t) {
    var start = ClinicalTrials.monthYear(t.StartDate);

    if (t.CompletionDate) {
        return start + ' → ' + ClinicalTrials.monthYear(t.CompletionDate);
    }
    if (t.EstimatedCompletionDate) {
        return start + ' → ' + ClinicalTrials.monthYear(t.EstimatedCompletionDate) + ' (est.)';
    }
    return start;
};

/**
 * Normalize condition strings:
 * Input often looks like:
 *   "Cancer,Diabetes"
 *   "Uterine Fibroids,Leiomyoma,Fibroid Uterus"
 *
 * Output becomes:
 *   "Cancer; Diabetes"
 *   "Uterine Fibroids; Leiomyoma; Fibroid Uterus"
 */
ClinicalTrials.conditionsText = function (s) {
    if (!s) return '';
    return s
        .split(',')
        .map(function (x) { return x.trim(); })
        .filter(Boolean)
        .join('; ');
};