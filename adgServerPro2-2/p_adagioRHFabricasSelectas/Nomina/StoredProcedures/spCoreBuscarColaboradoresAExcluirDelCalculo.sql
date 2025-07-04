USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento Core para Eliminar colaboradores del calculo de Nomina.
					  Este procedimiento es llamado desde [Nomina].[spBuscarColaboradoresAExcluirDelCalculo]
** Autor			: Jose Rafael Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2022-09-22
** Paremetros		:              
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/ 
CREATE PROCEDURE [Nomina].[spCoreBuscarColaboradoresAExcluirDelCalculo]
(
	@FechaIni date
	,@FechaFin date
	,@empleados [RH].[dtEmpleados] readonly                  
	,@fechasUltimaVigencia [App].[dtFechasVigenciaEmpleado] readonly 
	,@IDPeriodo int
	,@ExcluirBajas bit =1 
	,@IDUsuario int        
)
AS
BEGIN
		select e.*
		from @empleados e
			join @fechasUltimaVigencia fuv on e.IDEmpleado = fuv.IDEmpleado
		where fuv.Vigente = 0
END
GO
