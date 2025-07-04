USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca ciclos de medicion asociados a un aumento por desempeño
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2024-12-27
** Paremetros		:              

** DataTypes Relacionados: 

 Si se modifica el result set de este sp será necesario modificar también los siguientes SP's:

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   proc [Nomina].[spBuscarControlAumentosDesempenoCiclosMedicion](
	@IDControlAumentosDesempeno int 	
	,@IDUsuario int
) as

    SET FMTONLY OFF
	
	BEGIN -- Set Idioma 
 		DECLARE  
			@IDIdioma VARCHAR(5)
			,@IdiomaSQL VARCHAR(100) = null
		;

		SET DATEFIRST 7;

		select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

		select @IdiomaSQL = [SQL]
		from app.tblIdiomas
		where IDIdioma = @IDIdioma

		if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
		begin
			set @IdiomaSQL = 'Spanish' ;
		end
  
		SET LANGUAGE @IdiomaSQL;
	end

	SELECT 
		cadc.IDControlAumentosDesempenoCiclo
        ,cadc.IDControlAumentosDesempeno
        ,ccmo.IDCicloMedicionObjetivo
		,UPPER(ccmo.Nombre) as Nombre
		,ccmo.FechaInicio
		,ccmo.FechaFin
		,ccmo.IDEstatusCicloMedicion
		,UPPER(JSON_VALUE(ecm.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre'))) as EstatusCicloMedicion
		,ccmo.FechaParaActualizacionEstatusObjetivos
        ,ccmo.PermitirIngresoObjetivosEmpleados
        ,ccmo.EmpleadoApruebaObjetivos
        ,ccmo.IDUsuario
		,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario        	
    FROM Evaluacion360.tblCatCiclosMedicionObjetivos ccmo
		INNER JOIN Evaluacion360.tblCatEstatusCiclosMedicion ecm on ecm.IDEstatusCicloMedicion = ccmo.IDEstatusCicloMedicion
		INNER JOIN  Seguridad.tblUsuarios u on u.IDUsuario = ccmo.IDUsuario
        INNER JOIN [Nomina].[tblControlAumentosDesempenoCiclosMedicion] cadc ON cadc.IDCicloMedicionObjetivo = ccmo.IDCicloMedicionObjetivo AND cadc.IDControlAumentosDesempeno = @IDControlAumentosDesempeno
GO
