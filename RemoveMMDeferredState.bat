@sc stop FWASvc
@TIMEOUT 5
@del "%PROGRAMDATA%\Faronics\StorageSpace\FWA\FwaState.dat"
@sc start FWASvc

