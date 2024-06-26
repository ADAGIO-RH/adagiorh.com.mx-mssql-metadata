USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spIUProyecto](
	 @IDProyecto int
	,@Nombre varchar(255) 
	,@Descripcion nvarchar(max)	
	,@AutoEvaluacion bit = 0	
	,@IDUsuario int 
) AS
	declare 
		@IDEscalaValoracion int
		,@Min int = 0
		,@Max int = 0
		,@Row int = 0
		,@ConfigAutoevaluacionRequerida nvarchar(max)
		;

	IF object_id('tempdb..#tempEscalaProyecto') IS NOT NULL DROP TABLE #tempEscalaProyecto;
	--IF object_id('tempdb..#tempEvaluadoresReq') IS NOT NULL DROP TABLE #tempEvaluadoresReq;

	--CREATE TABLE #tempEvaluadoresReq(
	--	IDEvaluadorRequerido int
	--	,IDProyecto int
	--	,IDTipoRelacion int
	--	,Relacion varchar(255)
	--	,Minimo int
	--	,Maximo int
	--);

	select
		@Nombre = UPPER(@Nombre)
		,@Descripcion = UPPER(@Descripcion)

	if (@Nombre is null)
	begin
		raiserror('Ingrese el nombre del proyecto antes de continuar.',16,1);
		return;
	end;

	if (@IDProyecto = 0 or @IDProyecto is null)
	begin
		insert into [Evaluacion360].[tblCatProyectos](Nombre,Descripcion,FechaCreacion,IDUsuario)
		select @Nombre,@Descripcion,getdate(),@IDUsuario

		set @IDProyecto = @@IDENTITY

		INSERT [Evaluacion360].[tblEstatusProyectos] ([IDProyecto],[IDEstatus],[IDUsuario])
		values(@IDProyecto,1,@IDUsuario)

		select *, ROW_NUMBER()over(order By Total asc) as [Row]
		INTO #tempEscalaProyecto
		from (
			select ev.IDEscalaValoracion,Sum(dev.Valor)  as Total
			from Evaluacion360.tblCatEscalaValoracion ev with (nolock)
				join Evaluacion360.tblDetalleEscalaValoracion dev with (nolock) on ev.IDEscalaValoracion = dev.IDEscalaValoracion
			Group by ev.IDEscalaValoracion ) escalas

		if exists (select top 1 1 from #tempEscalaProyecto)
		begin
			select @Min = min(Row)
				 , @Max = max(row) from #tempEscalaProyecto

			set @Row = @Max / 2;

			select top 1 @IDEscalaValoracion = IDEscalaValoracion
			from #tempEscalaProyecto
			where [Row] = @Row		
			
			insert Evaluacion360.tblEscalasValoracionesProyectos (IDProyecto,Nombre,Valor)
			select @IDProyecto,Nombre, Valor
			from Evaluacion360.tblDetalleEscalaValoracion with (nolock)
			where IDEscalaValoracion = @IDEscalaValoracion
		end;

		exec [Evaluacion360].[spIniciarWizardUsuario]
			@IDProyecto = @IDProyecto 
			,@IDUsuario = @IDUsuario
	end else
	BEGIN

		begin try
			EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
		end try
		begin catch
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
			return 0;
		end catch

		update [Evaluacion360].[tblCatProyectos]
			set Nombre = @Nombre
				,Descripcion = @Descripcion
		where IDProyecto = @IDProyecto
	end;
	
	IF ((@AutoEvaluacion = 1) AND NOT EXISTS (SELECT TOP 1 1 
											FROM [Evaluacion360].[tblEvaluadoresRequeridos] with (nolock)
											WHERE IDProyecto = @IDProyecto AND IDTipoRelacion = 4 ))
	BEGIN
		--INSERT #tempEvaluadoresReq(IDEvaluadorRequerido,IDProyecto,IDTipoRelacion,Relacion,Minimo,Maximo)

		select @ConfigAutoevaluacionRequerida = [Valor]
				from [Evaluacion360].[tblConfiguracionAvanzadaProyecto] with (nolock)
				where IDConfiguracionAvanzada = 9 and IDProyecto  = @IDProyecto

		set @Min = case when LOWER(@ConfigAutoevaluacionRequerida) = 'true' then 0 else 1 end;

		EXEC [Evaluacion360].[spIUEvaluadorRequerido] 
			 @IDEvaluadorRequerido = 0
			,@IDProyecto		   = @IDProyecto
			,@IDTipoRelacion	   = 4
			,@Minimo			   = @Min
			,@Maximo			   = 1
			,@IDUsuario			  = @IDUsuario
			,@WithResult = 0
	END ELSE 
	IF ((@AutoEvaluacion = 0) and EXISTS (SELECT TOP 1 1 
										FROM [Evaluacion360].[tblEvaluadoresRequeridos] with (nolock)
										WHERE IDProyecto = @IDProyecto AND IDTipoRelacion = 4 ))
	BEGIN
		DELETE [Evaluacion360].[tblEvaluadoresRequeridos] 
		WHERE IDProyecto = @IDProyecto AND IDTipoRelacion = 4 
	END;

	exec [Evaluacion360].[spBuscarProyectos] @IDProyecto = @IDProyecto,@IDUsuario= @IDUsuario
GO
