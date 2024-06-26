USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spIniciarWizardUsuario](
	@IDProyecto int 
	,@IDUsuario int
	--,@Completo bit
) as
	declare @IDWizardUsuario int = 0;
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spIniciarWizardUsuario]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblDetalleWizardUsuario]',
		@Accion		varchar(20)	= 'INSERT',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	if not exists(select top 1 1
					from [Evaluacion360].[tblWizardsUsuarios] with (nolock)
					where IDProyecto = @IDProyecto and IDUsuario = @IDUsuario)
	begin
		insert into [Evaluacion360].[tblWizardsUsuarios](IDProyecto,IDUsuario,Completo,FechaHora)
		select @IDProyecto,@IDUsuario,0,getdate()
		
		set @IDWizardUsuario = @@IDENTITY

		insert [Evaluacion360].[tblDetalleWizardUsuario](IDWizardUsuario,IDWizardItem,Completo)
		select @IDWizardUsuario,IDWizardItem,case when IDWizardItem = 1 then 1 else 0 end
		from [Evaluacion360].[tblCatWizardItem] with (nolock)

		select @NewJSON = a.JSON
		from (
			select 
				 w.IDWizardUsuario
				,w.IDProyecto
				,p.Nombre as Proyecto
				,cw.*
				,w.IDUsuario
				,w.Completo
				FechaHora
			from [Evaluacion360].[tblWizardsUsuarios] w with (nolock)
				join Evaluacion360.[tblDetalleWizardUsuario] dw with (nolock) on dw.IDWizardUsuario = w.IDWizardUsuario
				join Evaluacion360.tblCatWizardItem cw with (nolock) on cw.IDWizardItem = dw.IDWizardItem
				join Evaluacion360.tblCatProyectos p with (nolock) on p.IDProyecto = w.IDProyecto
			where w.IDWizardUsuario = @IDWizardUsuario
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	end else 
	begin
		select @IDWizardUsuario=IDWizardUsuario
		from [Evaluacion360].[tblWizardsUsuarios] with (nolock)
		where IDProyecto = @IDProyecto and IDUsuario = @IDUsuario
	end;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= 'WIZARD INICIADO'
		,@InformacionExtra		= @InformacionExtra

	--exec [Evaluacion360].[spBuscarWizardUsuario] @IDWizardUsuario = @IDWizardUsuario


	--select * from app.tblCatModulos
GO
