<?php
$password = "475869"; // A senha que quer testar
$hash = password_hash($password, PASSWORD_DEFAULT);

echo "Senha original: " . $password . "<br>";
echo "Hash para colar na BD: " . $hash;
?>