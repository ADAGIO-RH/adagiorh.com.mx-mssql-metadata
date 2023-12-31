USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma035].[spBuscarDenuncias]
(@Admin INT = 0
,@IDUsuario INT)
as
BEGIN
	IF (@Admin = 1)
	BEGIN
	select  D.IDDenuncia
			,TD.Descripcion as TipoDenuncia
			,esAnonima
			,concat(CONVERT(VARCHAR,Fecha,103), ' ', CONVERT(VARCHAR,Fecha,108)) as FechaHora
			,Titulo
			,NombreDenunciado
			,D.Descripcion as DescDenuncia
			,D.IDTipoDenuncia
			,D.IDEmpleado
			,D.Estatus
			,D.Fecha
			,count(MD.IDMensajeDenuncia) as numMensajes
	from [Norma035].[tblDenuncias] D
	join [Norma035].[tblCatTiposDenuncia] TD ON D.IDTipoDenuncia = TD.IDTipoDenuncia
	left join Norma035.tblMensajesDenuncia MD on D.IDDenuncia = MD.IDDenuncia
	WHERE D.Estatus > 0
	group by 
	  D.IDDenuncia
	 ,TD.Descripcion
	 ,esAnonima
	 ,Fecha
	 ,Titulo
	 ,NombreDenunciado
	 ,D.Descripcion
	 ,D.IDTipoDenuncia
	 ,D.IDEmpleado
	 ,D.Estatus
	 ,D.Fecha

	END

	ELSE

	BEGIN
		select  D.IDDenuncia
			,TD.Descripcion as TipoDenuncia
			,esAnonima
			,concat(CONVERT(VARCHAR,Fecha,103), ' ', CONVERT(VARCHAR,Fecha,108)) as FechaHora
			,Titulo
			,NombreDenunciado
			,D.Descripcion as DescDenuncia
			,D.IDTipoDenuncia
			,D.IDEmpleado
			,D.Estatus
			,D.Fecha
			,count(MD.IDMensajeDenuncia) as numMensajes
			from [Norma035].[tblDenuncias] D
			join [Norma035].[tblCatTiposDenuncia] TD ON D.IDTipoDenuncia = TD.IDTipoDenuncia
			left join Norma035.tblMensajesDenuncia MD on D.IDDenuncia< = MD.IDDenuncia
			WHERE D.Estatus > 0
			AND D.IDEmpleado = @IDUsuario
			group by 
				D.IDDenuncia
				,TD.Descripcion
				,esAnonima
				,Fecha
				,Titulo
				,NombreDenunciado
				,D.Descripcion
				,D.IDTipoDenuncia
				,D.IDEmpleado
				,D.Estatus
				,D.Fecha
		END
	end
GO
