USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	EXEC [RH].[spAsignarColaboradorAPosicion]
		@IDPosicion = 61, 
		@IDEmpleado = 390, 
		@SueldoAsignado = 145, 
		@FechaAplicacion = '2022-05-06',  
		@IDUsuario = 1
*/

CREATE proc [RH].[spAsignarColaboradorAPosicion](
	@IDPosicion int,
    @IDPosicionAnterior int,
	@IDEmpleado int,
	@SueldoAsignado decimal(18,2)=0,
	@FechaAplicacion date= null,
    @flagMoverPosicion bit = 0,
    @dtHistorial_a_Modificar [Nomina].[dtFiltrosRH] Readonly,
    
	@IDUsuario int
) as
	declare 
		@IDPlaza int
		,@IDPlazaAnterior int		
        -- ,@AsignacionMultiplePosicion bit
	;

    -- select @AsignacionMultiplePosicion = cast( valor as bit) 
	-- from app.tblConfiguracionesGenerales with(nolock)
	-- where IDConfiguracion = 'AsignacionMultiplePosicion'


	IF(isnull(@FechaAplicacion,'') = '')
	BEGIN
		SET @FechaAplicacion = CAST(GETDATE() as date)
	END

	BEGIN TRY
		BEGIN TRAN AsignarColaboradorAPosicion

            -- select 1/0 ; -- provocar excepcion

			-- select top 1
			-- 	@IDPosicionAnterior = IDPosicion,
			-- 	@IDPlazaAnterior = IDPlaza
			-- from RH.tblCatPosiciones with(nolock)
			-- where IDEmpleado = @IDEmpleado
     
            -- if @IDPosicionAnterior > 0
            -- begin             
            if(isnull(@IDPosicionAnterior,0) > 0)
            BEGIN
                update RH.tblCatPosiciones 
                    set
                        IDEmpleado = null
                where IDPosicion = @IDPosicionAnterior

                -- Estatus de libre
                insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
                select @IDPosicionAnterior,2,@IDUsuario,null

                EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza=@IDPlazaAnterior, @IDUsuario=@IDUsuario
                -- exec [RH].[spActualizarJefesEmpleadosSubordinados] @IDPosicion=@IDPosicionAnterior;
                exec [RH].[spAsignarJefesEmpleadosOrganigramaIndividual] @IDPosicion=@IDPosicionAnterior
            END
            -- end

			select 
				@IDPlaza = IDPlaza
			from RH.tblCatPosiciones with(nolock)
			where IDPosicion = @IDPosicion

			EXEC [Reclutamiento].[spAplicarHistorialesAEmpleado]  
				@IDPosicion = @IDPosicion, 
				@IDEmpleado = @IDEmpleado, 
				@SueldoAsignado = @SueldoAsignado, 
				@FechaAplicacion = @FechaAplicacion,  
				@IDUsuario = @IDUsuario,
                @dtHistorial_a_Modificar=@dtHistorial_a_Modificar

			update RH.tblCatPosiciones
				set
					IDEmpleado = @IDEmpleado
			where IDPosicion = @IDPosicion

			-- Estatus de Ocupada
			insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
			select @IDPosicion,3,@IDUsuario,@IDEmpleado

			EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza=@IDPlaza, @IDUsuario=@IDUsuario

            declare @IDPosicionConMayorJerarquia int,@IDOrganigrama int ,  @TotalPosicionesAlMismoNivel int;
            select @IDOrganigrama = IDOrganigrama from rh.tblCatPlazas where IDPlaza=@IDPlaza;
            
            
              with CTE_Jerarquias as(
                select 1 rowNo ,ParentId, IDPosicion as IDPosicionMayorJerarquia from rh.tblCatPosiciones with (nolock) where IDPosicion= @IDPosicion
                UNION ALL 
                SELECT  rowNo +1  as rowNo,po.ParentId, case when po.IDEmpleado= @IDEmpleado then po.IDPosicion else CTE_Jerarquias.IDPosicionMayorJerarquia end as IDPosicionMayorJerarquia                             
                from CTE_Jerarquias  
                INNER JOIN RH.tblCatPosiciones PO ON PO.IDPosicion=CTE_Jerarquias.ParentId
            )                
            select   @TotalPosicionesAlMismoNivel=totalPosicionesAlMismoNivel ,@IDPosicionConMayorJerarquia= (select top 1 IDPosicionMayorJerarquia  from CTE_Jerarquias order by rowNo desc) 
            from  (
                SELECT count(*)  as totalPosicionesAlMismoNivel 
                FROM rh.tblCatPosiciones 
                WHERE IDEmpleado=@IDEmpleado and 
                    ParentId= (select ParentId from  rh.tblCatPosiciones where IDPosicion= (select top 1 IDPosicionMayorJerarquia  from CTE_Jerarquias order by rowNo desc))
            ) as temp ;

            IF @TotalPosicionesAlMismoNivel > 1
            BEGIN
                EXEC  [RH].[spAsignarJefeEmpleadosByIDOrganigrama] @IDOrganigrama=@IDOrganigrama;
            END ELSE BEGIN
                EXEC [RH].[spAsignarJefesEmpleadosOrganigramaIndividual] @IDPosicion=@IDPosicionConMayorJerarquia;
            END
     
            
			COMMIT TRANSACTION AsignarColaboradorAPosicion
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION; 
		DECLARE @MESSAGE VARCHAR(max) =  ERROR_MESSAGE(),
			@SEVERITY VARCHAR(max) =  ERROR_SEVERITY(),
			@STATE VARCHAR(max) =  ERROR_STATE();
            
		RAISERROR(  
			@MESSAGE
			,@SEVERITY
			,@STATE );
        
	END CATCH;
GO
