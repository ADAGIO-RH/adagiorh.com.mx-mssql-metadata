USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [IMSS].[spUIMovAfiliatorio]    
(    
	@IDMovAfiliatorio int = 0,    
	@Fecha date,    
	@IDEmpleado int,    
	@IDTipoMovimiento int,    
	@FechaIMSS date = null,    
	@FechaIDSE date = null,    
	@IDRazonMovimiento int,    
	@SalarioDiario decimal(9,2),    
	@SalarioIntegrado decimal(9,2),    
	@SalarioVariable decimal(9,2),    
	@SalarioDiarioReal decimal(9,2),    
	@IDRegPatronal int,
	@RespetarAntiguedad bit = 0,
	@IDUsuario int = 0 ,   
	@IDTipoRazonMovimiento int=0,    
	@FechaUltimoDiaLaborado date = null,    
	@Comentario VARCHAR(500)=NULL
)    
AS    
BEGIN    
  
	declare 
		@codigoMov varchar(10)  
		,@UltimoMovEmpleado varchar(10)
        ,@ultimoSalarioDiario decimal(18,2)=0
        ,@UltimoSalarioVariable decimal(18,2)=0
        ,@UltimoSalarioReal decimal(18,2)=0
        ,@UltimoSDI decimal(18,2)=0    
		,@UMA decimal(18,2)  = 0  
		,@SalarioMinimo decimal(18,2) = 0  
		,@FechaAlta date
		,@IDMovAlta int
        ,@IDUsuarioTemp int

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);
  
	set @IDRegPatronal = case when @IDRegPatronal = 0 then null else @IDRegPatronal end
	set @codigoMov = (select top 1 Codigo   
					 from IMSS.tblCatTipoMovimientos with (nolock)  
					 where IDTipoMovimiento = @IDTipoMovimiento)  
  
	if (@IDTipoMovimiento = 4 and @IDRegPatronal is null)
	begin
		select @IDRegPatronal = IDRegPatronal
		from [RH].[tblRegPatronalEmpleado] RPE WITH(NOLOCK)              
		where RPE.IDEmpleado = @IDEmpleado AND RPE.FechaIni<= @Fecha and RPE.FechaFin >= @Fecha              
	end

	select top 1 @UMA = UMA
			, @SalarioMinimo = SalarioMinimo -- Aqui se obtiene el valor de la UMA del catalogo de Salarios minimos  
	from Nomina.tblSalariosMinimos with (nolock)   
	where Year(Fecha) = YEAR(@Fecha)  
	Order by Fecha Desc  

	----- TOPE DE SALARIO INTEGRADO
	set @SalarioIntegrado = CASE WHEN (isnull(@UMA,0) > 0) and (@SalarioIntegrado > (isnull(@UMA,0) * 25)) THEN (isnull(@UMA,0) * 25)
								ELSE @SalarioIntegrado
							END

	select top 1 @FechaAlta = mov.Fecha, @IDMovAlta = mov.IDMovAfiliatorio 
	from IMSS.tblMovAfiliatorios mov with (nolock)  
		inner join IMSS.tblCatTipoMovimientos tmov with (nolock)  
			on mov.IDTipoMovimiento = tmov.IDTipoMovimiento  
	where mov.IDEmpleado = @IDEmpleado and tmov.Codigo = 'A'
	order by Fecha desc	

  
	IF(@IDMovAfiliatorio = 0 or @IDMovAfiliatorio is null)    
	BEGIN    
		select top 1 
			@UltimoMovEmpleado = tmov.Codigo
			,@ultimoSalarioDiario= mov.SalarioDiario
			,@UltimoSalarioVariable=mov.SalarioVariable
			,@UltimoSDI=mov.SalarioIntegrado
			,@UltimoSalarioReal=mov.SalarioDiarioReal 
		from IMSS.tblMovAfiliatorios mov with (nolock)  
			inner join IMSS.tblCatTipoMovimientos tmov with (nolock)  
				on mov.IDTipoMovimiento = tmov.IDTipoMovimiento  
		where mov.IDEmpleado = @IDEmpleado  
		order by Fecha desc  
  
		if (exists (select top 1 1 
					from IMSS.tblMovAfiliatorios mov with (nolock)  
						inner join IMSS.tblCatTipoMovimientos tmov with (nolock)  
						on mov.IDTipoMovimiento = tmov.IDTipoMovimiento  
					where mov.IDEmpleado = @IDEmpleado and tmov.Codigo = 'A') and (@codigoMov = 'A'))  
		BEGIN  
			RAISERROR ('Este empleado ya tiene una alta', 16, 1);  
			RETURN 0;  
		END  

		IF(@Fecha < @FechaAlta)
		BEGIN
			RAISERROR ('No se pueden agregar movimientos previo a la fecha de Alta.', 16, 1);  
			RETURN 0; 
		END
  
		IF(@codigoMov = 'R' and @UltimoMovEmpleado <> 'B')  
		BEGIN  
			RAISERROR ('Para Guardar un Reingreso a un empleado, debe tener una Baja(B) previa.', 16, 1);  
			RETURN 0;  
		END  
  
		IF(@codigoMov = 'M' and @UltimoMovEmpleado = 'B')  
		BEGIN  
			RAISERROR ('Para Guardar un Movimiento Salarial a un empleado, su movimiento previo no debe ser baja.', 16, 1);  
			RETURN 0;  
		END  
  
		IF(@codigoMov = 'A' and @UltimoMovEmpleado = 'A')  
		BEGIN  
			RAISERROR ('Este empleado ya tiene una alta.', 16, 1);  
			RETURN 0;  
		END  
  
		IF(@codigoMov = 'B' and @UltimoMovEmpleado = 'B')  
		BEGIN  
			RAISERROR ('Este empleado ya tiene una Baja Previa.', 16, 1);  
			RETURN 0;  
		END  
  
		IF(@codigoMov = 'R' and @UltimoMovEmpleado = 'R')  
		BEGIN  
			RAISERROR ('Este empleado ya tiene un Reingreso Previo.', 16, 1);  
			RETURN 0;  
		END  
  
		if (exists (select top 1 1 
					from IMSS.tblMovAfiliatorios mov with (nolock)  
						inner join IMSS.tblCatTipoMovimientos tmov with (nolock)  
							on mov.IDTipoMovimiento = tmov.IDTipoMovimiento  
					where mov.IDEmpleado = @IDEmpleado and mov.Fecha = @Fecha))  
		BEGIN  
			RAISERROR ('Ya existe un movimiento con esta fecha', 16, 1);  
			RETURN 0;  
		END  

        IF(@codigoMov = 'B')  
		BEGIN  
			SET @SalarioDiario=@ultimoSalarioDiario
            SET @SalarioDiarioReal=@UltimoSalarioReal
            SET @SalarioIntegrado=@UltimoSDI
            SET @SalarioVariable=@UltimoSalarioVariable
		END  

            
		INSERT INTO IMSS.tblMovAfiliatorios(Fecha,IDEmpleado,IDTipoMovimiento,FechaIMSS,FechaIDSE,IDRazonMovimiento,IDTipoRazonMovimiento,SalarioDiario,SalarioIntegrado,SalarioVariable,SalarioDiarioReal,IDRegPatronal,RespetarAntiguedad,FechaUltimoDiaLaborado,Comentario)    
		values( @Fecha,@IDEmpleado,@IDTipoMovimiento,@FechaIMSS,@FechaIDSE    
			,CASE WHEN (@IDRazonMovimiento = 0) THEN NULL ELSE @IDRazonMovimiento END    
			,CASE WHEN (@IDTipoRazonMovimiento = 0) THEN NULL ELSE @IDTipoRazonMovimiento END                
			,@SalarioDiario,@SalarioIntegrado,@SalarioVariable,@SalarioDiarioReal,@IDRegPatronal,@RespetarAntiguedad
			,@FechaUltimoDiaLaborado,@Comentario)    
    
		SET @IDMovAfiliatorio = @@IDENTITY    

        exec [IMSS].[spCalcularFechaAntiguedadMovAfiliatorios]  @IDMovAfiliatorio=@IDMovAfiliatorio;

		select @NewJSON = a.JSON from [IMSS].[tblMovAfiliatorios] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMovAfiliatorio = @IDMovAfiliatorio

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblMovAfiliatorios]','[IMSS].[spUIMovAfiliatorio]','INSERT',@NewJSON,''

        EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblSaldoVacacionesEmpleado]','[IMSS].[spUIMovAfiliatorio]','INSERT',@NewJSON,'','GENERACION DE VACACIONES POR CAMBIO DE MOVIMIENTO AFILIATORIO'	

		IF EXISTS( SELECT 1 FROM RH.tblContratoEmpleado ce inner join RH.tblCatDocumentos d on ce.IDDocumento = d.IDDocumento and ISNULL(d.EsContrato,0) = 1 where ce.IDEmpleado = @IDEmpleado and @Fecha Between ce.FechaIni and ce.FechaFin) AND @codigoMov = 'B'
		BEGIN
			INSERT INTO RH.tblMovAfiliatorioBajaContrato(IDMovAfiliatorio,IDContratoEmpleado)
			SELECT @IDMovAfiliatorio,ce.IDContratoEmpleado 
			FROM RH.tblContratoEmpleado ce with(nolock) 
				inner join RH.tblCatDocumentos d with(nolock) 
					on ce.IDDocumento = d.IDDocumento and ISNULL(d.EsContrato,0) = 1 
			where ce.IDEmpleado = @IDEmpleado and @Fecha Between ce.FechaIni and ce.FechaFin
		
			update CE
				set ce.FechaFin = @Fecha 
			FROM RH.tblContratoEmpleado ce 
				inner join RH.tblCatDocumentos d 
					on ce.IDDocumento = d.IDDocumento 
					and ISNULL(d.EsContrato,0) = 1 
			where ce.IDEmpleado = @IDEmpleado and @Fecha Between ce.FechaIni and ce.FechaFin
		END

        EXEC [Scheduler].[spSchedulerNotificacionEspecial_NuevoMovimientoAfiliatorio]  
        @IDMovimientoAfiliatorio=@IDMovAfiliatorio    

		exec [IMSS].[spBuscarMovAfiliatorio] @IDMovAfiliatorio=@IDMovAfiliatorio    

        
	END    
	ELSE    
	BEGIN    
		select top 1 
        @UltimoMovEmpleado = tmov.Codigo
        ,@ultimoSalarioDiario= mov.SalarioDiario
        ,@UltimoSalarioVariable=mov.SalarioVariable
        ,@UltimoSDI=mov.SalarioIntegrado
        ,@UltimoSalarioReal=mov.SalarioDiarioReal 
        from IMSS.tblMovAfiliatorios mov  
			inner join IMSS.tblCatTipoMovimientos tmov with (nolock)  
				on mov.IDTipoMovimiento = tmov.IDTipoMovimiento  
		where mov.IDEmpleado = @IDEmpleado and mov.IDMovAfiliatorio <> @IDMovAfiliatorio and mov.Fecha <= @Fecha  
		order by Fecha desc  
  
		if (exists (select top 1 1 
					from IMSS.tblMovAfiliatorios mov  
						inner join IMSS.tblCatTipoMovimientos tmov  
							on mov.IDTipoMovimiento = tmov.IDTipoMovimiento  
					where mov.IDEmpleado = @IDEmpleado and mov.IDMovAfiliatorio <> @IDMovAfiliatorio and tmov.Codigo = 'A') and (@codigoMov = 'A'))  
		BEGIN  
			RAISERROR ('Este empleado ya tiene una alta', 16, 1);  
			RETURN 0;  
		END  
		
   		IF(@Fecha < @FechaAlta and @codigoMov = 'B')  
		BEGIN  
			RAISERROR ('La Fecha de Baja no puede ser previa a la Fecha de Alta.', 16, 1);  
			RETURN 0;  
		END  
        
  
		IF(@Fecha < @FechaAlta and @IDMovAfiliatorio <> @IDMovAlta)
		BEGIN
			RAISERROR ('No se pueden agregar movimientos previo a la fecha de Alta.', 16, 1);  
			RETURN 0; 
		END
  
		IF(@codigoMov = 'R' and @UltimoMovEmpleado <> 'B')  
		BEGIN  
			RAISERROR ('Para Guardar un Reingreso a un empleado, debe tener una Baja(B) previa.', 16, 1);  
			RETURN 0;  
		END  
  
		IF(@codigoMov = 'M' and @UltimoMovEmpleado = 'B')  
		BEGIN  
			RAISERROR ('Para Guardar un Movimiento Salarial a un empleado, su movimiento previo no debe ser baja.', 16, 1);  
			RETURN 0;  
		END  
  
		IF(@codigoMov = 'A' and @UltimoMovEmpleado = 'A')  
		BEGIN  
			RAISERROR ('Este empleado ya tiene una alta.', 16, 1);  
			RETURN 0;  
		END  

     
		IF(@codigoMov = 'B' and @UltimoMovEmpleado = 'B')  
		BEGIN  
			RAISERROR ('Este empleado ya tiene una Baja Previa.', 16, 1);  
			RETURN 0;  
		END  
  
		IF(@codigoMov = 'R' and @UltimoMovEmpleado = 'R')  
		BEGIN  
			RAISERROR ('Este empleado ya tiene un Reingreso Previo.', 16, 1);  
			RETURN 0;  
		END  
  
		if (exists (select top 1 1 
					from IMSS.tblMovAfiliatorios mov with (nolock)  
						inner join IMSS.tblCatTipoMovimientos tmov with (nolock)  
							on mov.IDTipoMovimiento = tmov.IDTipoMovimiento  
					where mov.IDEmpleado = @IDEmpleado and mov.Fecha = @Fecha and mov.IDMovAfiliatorio <> @IDMovAfiliatorio))  
		BEGIN  
			RAISERROR ('Ya existe un movimiento con esta fecha', 16, 1);  
			RETURN 0;  
		END  

        IF(@codigoMov = 'B')  
		BEGIN  
			SET @SalarioDiario=@ultimoSalarioDiario
            SET @SalarioDiarioReal=@UltimoSalarioReal
            SET @SalarioIntegrado=@UltimoSDI
            SET @SalarioVariable=@UltimoSalarioVariable
		END  
        
		select @OldJSON = a.JSON from [IMSS].[tblMovAfiliatorios] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMovAfiliatorio = @IDMovAfiliatorio
  
		UPDATE IMSS.tblMovAfiliatorios    
		SET Fecha = @Fecha    
			,IDEmpleado = @IDEmpleado    
			,IDTipoMovimiento = @IDTipoMovimiento    
			,FechaIMSS = @FechaIMSS    
			,FechaIDSE = @FechaIDSE    
			,IDRazonMovimiento = case when @IDRazonMovimiento = 0 then null else @IDRazonMovimiento end    
			,IDTipoRazonMovimiento = case when @IDTipoRazonMovimiento = 0 then null else @IDTipoRazonMovimiento end    
			,SalarioDiario = @SalarioDiario    
			,SalarioIntegrado = @SalarioIntegrado    
			,SalarioVariable = @SalarioVariable    
			,SalarioDiarioReal = @SalarioDiarioReal    
			,IDRegPatronal = @IDRegPatronal
			,RespetarAntiguedad = @RespetarAntiguedad    
			,FechaUltimoDiaLaborado=@FechaUltimoDiaLaborado
			,Comentario=@Comentario
		WHERE IDMovAfiliatorio = @IDMovAfiliatorio    
  
        exec [IMSS].[spCalcularFechaAntiguedadMovAfiliatorios]  @IDMovAfiliatorio=@IDMovAfiliatorio;

		select @NewJSON = a.JSON from [IMSS].[tblMovAfiliatorios] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMovAfiliatorio = @IDMovAfiliatorio

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblMovAfiliatorios]','[IMSS].[spUIMovAfiliatorio]','UPDATE',@NewJSON,@OldJSON

        EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblSaldoVacacionesEmpleado]','[IMSS].[spUIMovAfiliatorio]','UPDATE',@NewJSON,@OldJSON,'GENERACION DE VACACIONES POR CAMBIO DE MOVIMIENTO AFILIATORIO'		
  
		IF EXISTS( SELECT 1 FROM RH.tblMovAfiliatorioBajaContrato where IDMovAfiliatorio = @IDMovAfiliatorio) AND @codigoMov = 'B'
		BEGIN
			update RH.tblContratoEmpleado 
				set FechaFin = @Fecha
			where IDContratoEmpleado in (select IDContratoEmpleado from RH.tblMovAfiliatorioBajaContrato where IDMovAfiliatorio = @IDMovAfiliatorio)
		END
		exec [IMSS].[spBuscarMovAfiliatorio] @IDMovAfiliatorio=@IDMovAfiliatorio    
	END    
    
	declare @IDRegpatronalActual int  
  
	set @IDRegpatronalActual = (Select top 1 IDRegPatronal from RH.tblRegPatronalEmpleado where IDEmpleado = @IDEmpleado order by FechaFin desc)  
  
  
	if(@IDRegPatronal <> @IDRegpatronalActual and @IDTipoMovimiento = 3)  
	BEGIN  
		exec [RH].[spUIRegPatronalEmpleado]  
			@IDEmpleado = @IDEmpleado  
			,@IDRegPatronal = @IDRegPatronal   
			,@FechaIni = @Fecha    
			,@FechaFin = '9999-12-31'    
			,@IDUsuario = @IDUsuario
	END  

    if( @IDTipoMovimiento = 3)  
	BEGIN  	
        select @IDUsuarioTemp=s.IDUsuario  from  Seguridad.tblUsuarios as s where s.IDEmpleado=@IDEmpleado

        update Seguridad.tblUsuarios
	    set   Activo = 1
        where IDUsuario = @IDUsuarioTemp
               
	END  

	EXEC [IMSS].[spIUVigenciaEmpleado] @IDEmpleado = @IDEmpleado

	UPDATE E
		set e.FechaAntiguedad = CASE WHEN isnull(M.FechaReingreso,'1900-01-01') >= M.FechaAlta THEN ISNULL(M.FechaReingreso,'1900-01-01')              
			ELSE M.FechaAlta              
			END  
	FROM RH.tblEmpleados E
		inner join IMSS.TblVigenciaEmpleado M
			on E.IDEmpleado = M.IDEmpleado

	IF(@codigoMov = 'B')
	BEGIN
		declare 
			@IDPlaza int
			,@IDPlazaAnterior int
			,@IDPosicionAnterior int
		;

			select top 1
				@IDPosicionAnterior = IDPosicion,
				@IDPlazaAnterior = IDPlaza
			from RH.tblCatPosiciones with(nolock)
			where IDEmpleado = @IDEmpleado

			if(isnull(@IDPosicionAnterior,0) > 0)
			BEGIN
				update RH.tblCatPosiciones 
					set
						IDEmpleado = null
				where IDPosicion = @IDPosicionAnterior

				-- Estatus de Ocupada
				insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
				select @IDPosicionAnterior,2,@IDUsuario,null

				EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza=@IDPlazaAnterior, @IDUsuario=@IDUsuario
			 END
	END

    
    

	DECLARE @tran INT   
	SET @tran = @@TRANCOUNT  
	IF(@tran = 0)  
	BEGIN

		EXEC [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado 
        
        IF(@codigoMov = 'R') 
        BEGIN
        EXEC [Asistencia].[spSchedulerGeneracionVacaciones]  @IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario
        END
      
	END   
END
GO
