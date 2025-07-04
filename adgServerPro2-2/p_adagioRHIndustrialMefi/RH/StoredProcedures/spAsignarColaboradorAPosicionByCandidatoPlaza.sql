USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spAsignarColaboradorAPosicionByCandidatoPlaza] --11,4405,1
(
	@IDCandidatoPlaza int,
	@IDEmpleado int,
	@IDUsuario int
) as
	declare 
		@IDPlaza int
		,@IDPlazaAnterior int
		,@IDPosicion int
		,@IDPosicionAnterior int
		,@IDCandidato int
		,@ID_ESTATUS_POSICION_AUTORIZADA_DISPONIBLE int = 2
		,@ID_ESTATUS_POSICION_OCUPADA int = 3
	;

	select 
		@IDCandidato = IDCandidato,
		@IDPlaza = IDPlaza
	from Reclutamiento.tblCandidatoPlaza
	where IDCandidatoPlaza = @IDCandidatoPlaza

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
		insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado, ContratoDesdeReclutamiento)
		select @IDPosicionAnterior, @ID_ESTATUS_POSICION_AUTORIZADA_DISPONIBLE,@IDUsuario,null, cast(1 as bit)

		EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza=@IDPlazaAnterior, @IDUsuario=@IDUsuario
	 END

	IF object_ID('TEMPDB..#TempPosiciones') IS NOT NULL DROP TABLE #TempPosiciones
	
	Select p.IDPlaza 
		, p.IDPosicion
		, p.IDEmpleado
	into #TempPosiciones
	from RH.tblCatPosiciones P with(nolock)
	WHERE p.IDPlaza = @IDPlaza and p.IDEmpleado is null

	select top 1 @IDPosicion = p.IDPosicion 
				-- ,@IDPlaza = p.IDPlaza
	from RH.tblCatPosiciones p
	where  p.IDEmpleado is null 
		and p.IDPosicion in (select IDPosicion from #TempPosiciones where IDEmpleado is null)
		and ( 
				select  top 1 IDEstatus  
				from RH.tblEstatusPosiciones pp with(nolock) 
				where pp.IDPosicion=p.IDPosicion 
				order by fechaReg desc 
			) = @ID_ESTATUS_POSICION_AUTORIZADA_DISPONIBLE

	update p
		set
			IDEmpleado = @IDEmpleado
	from RH.tblCatPosiciones p
	where IDPosicion = @IDPosicion

	-- Estatus de Ocupada
	insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
	select @IDPosicion, @ID_ESTATUS_POSICION_OCUPADA,@IDUsuario,@IDEmpleado

	UPDATE Reclutamiento.tblCandidatos
		SET IDEmpleado = @IDEmpleado
	WHERE IDCandidato = @IDCandidato

	EXEC [RH].[spActualizarTotalesPosiciones] @IDPlaza=@IDPlaza, @IDUsuario=@IDUsuario
GO
