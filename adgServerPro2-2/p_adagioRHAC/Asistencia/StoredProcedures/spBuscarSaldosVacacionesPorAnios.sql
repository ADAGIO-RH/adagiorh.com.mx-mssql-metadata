USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************   
** Descripción  : Calcula el historial de saldos de vacaciones de un colaborador  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2019-01-01  
** Paremetros  :                
  
 Si se modifica el result set de este sp será necesario modificar los siguientes SP's:  
  [Asistencia].[spBuscarVacacionesPendientesEmpleado]  
  
** DataTypes Relacionados:   [Asistencia].[dtSaldosDeVacaciones]  
  
  select * from RH.tblEmpleadosMaster where claveEmpleado= 'adg0001'
[Asistencia].[spBuscarSaldosVacacionesPorAnios] 1279,1,1  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)		Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2022-08-04				José Roman 		Este Procedimiento se modifico para poder ser personalizado 
										en caso de que el cliente necesita alguna configuración
										especial.
***************************************************************************************************/  
  --exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado=390,@Proporcional=1,@IDUsuario=290
CREATE proc [Asistencia].[spBuscarSaldosVacacionesPorAnios]-- 390,0,1
(  
	 @IDEmpleado	int
	,@Proporcional	bit = null
	,@FechaBaja		date = null
	,@IDUsuario		int = 1
    ,@IDMovimientoBaja int = 0

) as  
BEGIN
	SET FMTONLY OFF;  
	
	DECLARE @IDCliente					int
			,@FechaFin					date = getdate()  
			,@spCustomSaldoVacaciones	Varchar(500);

   



    IF EXISTS(Select top 1 1 from app.tblConfiguracionesGenerales CG where IDConfiguracion = 'RefactorizacionVacaciones' and Valor = 1)
    BEGIN
    print 'REFACTOR PROCEDURE'
		/*
			EXEC REFACTOR  STORE PROCEDURE 
		*/

    EXEC [Asistencia].[spConsultarVacacionesPorAnio] 
			 @IDEmpleado	= @IDEmpleado
			,@Proporcional	= @Proporcional
			,@Date  		= @FechaBaja
			,@IDUsuario		= @IDUsuario
            ,@IDMovimientoBaja = @IDMovimientoBaja
    
    END
    ELSE
    BEGIN

    
	select
		 @IDCliente					= ce.IDCliente  
		,@spCustomSaldoVacaciones	= isnull(config.Valor,'')
	from [RH].[tblEmpleadosMaster] e with (nolock)  
		LEFT JOIN [RH].tblClienteEmpleado ce with (nolock) ON ce.IDEmpleado = e.IDEmpleado   
			and ce.FechaIni<= @FechaFin and ce.FechaFin >= @FechaFin     
		LEFT JOIN RH.[TblConfiguracionesCliente] config with (nolock) on config.IDCliente = ce.IDCliente
			and config.IDTipoConfiguracionCliente = 'spCustomSaldoVacaciones'
	where e.IDEmpleado = @IDEmpleado 
	
	IF(@spCustomSaldoVacaciones <> '')
	BEGIN
		print 'CUSTOME'
		/*
			EXEC CUSTOM STORE PROCEDURE 
		*/
		exec sp_executesql N'exec @miSP @IDEmpleado,@Proporcional,@FechaBaja,@IDUsuario'                   
			,N' @IDEmpleado		int                   
				,@Proporcional	bit                   
				,@FechaBaja		date                   
				,@IDUsuario		int                
				,@miSP			varchar(255)',                          
				@IDEmpleado		= @IDEmpleado                  
				,@Proporcional	= @Proporcional                  
				,@FechaBaja		= @FechaBaja                  
				,@IDUsuario		= @IDUsuario                         
				,@miSP			= @spCustomSaldoVacaciones;  
	END

	ELSE 
	BEGIN
		print 'CORE'
		/*
			EXEC CORE STORE PROCEDURE 
		*/
		EXEC [Asistencia].[spCoreBuscarSaldosVacacionesPorAnios] 
			 @IDEmpleado	= @IDEmpleado
			,@Proporcional	= @Proporcional
			,@FechaBaja		= @FechaBaja
			,@IDUsuario		= @IDUsuario
            ,@IDMovimientoBaja = @IDMovimientoBaja

	END

END

END
GO
