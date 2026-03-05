<?php
include "condb.php";

try {

    $stmt = $conn->query("SELECT * FROM places");
    $places = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($places);
    
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
