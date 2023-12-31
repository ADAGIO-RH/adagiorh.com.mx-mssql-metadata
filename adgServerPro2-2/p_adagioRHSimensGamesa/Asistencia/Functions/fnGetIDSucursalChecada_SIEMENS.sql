USE [p_adagioRHSimensGamesa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Asistencia].[fnGetIDSucursalChecada_SIEMENS](
	@latitud1 float,
	@longitud1 float
)
RETURNS INT
AS
BEGIN
	
  DECLARE @distancia float
		,@MetrosALaRedonda float
		,@IDSucursal int
  ;
  
  --Radio de la tierra según WGS84
  DECLARE @radius float
  SET @radius = 6378.137 

  DECLARE @deg2radMultiplier float 
  SET @deg2radMultiplier = PI() / 180
  
  SET @latitud1 = @latitud1 * @deg2radMultiplier
  SET @longitud1 = @longitud1 * @deg2radMultiplier

  set @MetrosALaRedonda = (select json_value ( (select valor from app.tblconfiguracionesgenerales with (nolock) where IDConfiguracion = 'RegistrarAsistenciaEnLogin'), '$.metros_a_la_redonda'))

  select top 1
	@IDSucursal = IDSucursal
	--,Descripcion
	--,Longitud
	--,Latitud
	--,(ACOS(SIN(@latitud1) * SIN(Latitud * @deg2radMultiplier) + COS(@latitud1) * 
 --                        COS(Latitud  * @deg2radMultiplier) * COS((Longitud * @deg2radMultiplier) - @longitud1)) * @radius) *1000 as Distancia
	from rh.tblCatSucursales
	where ((ACOS(SIN(@latitud1) * SIN(Latitud * @deg2radMultiplier) + COS(@latitud1) * 
                         COS(Latitud  * @deg2radMultiplier) * COS((Longitud * @deg2radMultiplier) - @longitud1)) * @radius) *1000) <= @MetrosALaRedonda
	
	RETURN ISNULL(@IDSucursal,0)
END
GO
