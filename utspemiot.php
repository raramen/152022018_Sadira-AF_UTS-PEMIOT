<?php
// Koneksi ke database
$host = "localhost"; 
$username = "root"; 
$password = ""; 
$dbname = "tb_cuaca"; 

$conn = new mysqli($host, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}

// Query untuk mendapatkan suhu max, suhu min, suhu rata-rata
$query_suhu = "SELECT MAX(suhu) AS suhumax, MIN(suhu) AS suhumin, ROUND(AVG(suhu), 2) AS suhurata FROM tb_cuaca";
$result_suhu = $conn->query($query_suhu);
$row_suhu = $result_suhu->fetch_assoc();

// Query untuk mendapatkan nilai suhu max dengan humid max
$query_max_humid = "SELECT id, suhu, humid, lux, ts FROM tb_cuaca WHERE suhu = (SELECT MAX(suhu) FROM tb_cuaca) AND humid = (SELECT MAX(humid) FROM tb_cuaca)";
$result_max_humid = $conn->query($query_max_humid);

// Query untuk mendapatkan bulan dan tahun max
$query_month_year_max = "SELECT DATE_FORMAT(ts, '%m-%Y') AS month_year FROM tb_cuaca WHERE suhu = (SELECT MAX(suhu) FROM tb_cuaca) AND humid = (SELECT MAX(humid) FROM tb_cuaca) ORDER BY ts DESC LIMIT 2";
$result_month_year_max = $conn->query($query_month_year_max);

// Menyusun data JSON
$data = [
    'suhumax' => (int)$row_suhu['suhumax'],
    'suhumin' => (int)$row_suhu['suhumin'],
    'suhurata' => (float)$row_suhu['suhurata'], // Menggunakan alias yang benar
    'nilai_suhu_max_humid_max' => [],
    'month_year_max' => []
];

// Menambahkan data suhu max dengan humid max
while ($row = $result_max_humid->fetch_assoc()) {
    $data['nilai_suhu_max_humid_max'][] = [
        'id' => (int)$row['id'],
        'suhu' => (int)$row['suhu'],
        'humid' => (int)$row['humid'],
        'kecerahan' => (int)$row['lux'],
        'timestamp' => $row['ts']
    ];
}

// Menambahkan data bulan dan tahun max
while ($row = $result_month_year_max->fetch_assoc()) {
    $data['month_year_max'][] = [
        'month_year' => $row['month_year']
    ];
}

// Menghasilkan JSON
header('Content-Type: application/json');
echo json_encode($data);

// Menutup koneksi
$conn->close();
?>