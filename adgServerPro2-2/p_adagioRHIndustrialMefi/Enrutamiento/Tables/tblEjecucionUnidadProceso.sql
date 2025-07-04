USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Enrutamiento].[tblEjecucionUnidadProceso](
	[IDEjecucionUnidadProceso] [int] IDENTITY(1,1) NOT NULL,
	[IDRutaUnidadProceso] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Realizado] [bit] NULL,
	[FechaHoraRealizacion] [datetime] NULL,
 CONSTRAINT [PK_EnrutamientoTblEjecucionUnidadProceso_IDEjecucionUnidadProceso] PRIMARY KEY CLUSTERED 
(
	[IDEjecucionUnidadProceso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Enrutamiento].[tblEjecucionUnidadProceso] ADD  CONSTRAINT [d_EnrutamientoTblEjecucionUnidadProceso_Realizado]  DEFAULT ((0)) FOR [Realizado]
GO
ALTER TABLE [Enrutamiento].[tblEjecucionUnidadProceso]  WITH CHECK ADD  CONSTRAINT [FK_EnrutamientoTblRutaUnidadProceso_EnrutamientoTblEjecucionUnidadProceso_IDRutaUnidadProceso] FOREIGN KEY([IDRutaUnidadProceso])
REFERENCES [Enrutamiento].[tblRutaUnidadProceso] ([IDRutaUnidadProceso])
GO
ALTER TABLE [Enrutamiento].[tblEjecucionUnidadProceso] CHECK CONSTRAINT [FK_EnrutamientoTblRutaUnidadProceso_EnrutamientoTblEjecucionUnidadProceso_IDRutaUnidadProceso]
GO
ALTER TABLE [Enrutamiento].[tblEjecucionUnidadProceso]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_EnrutamientoTblEjecucionUnidadProceso_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Enrutamiento].[tblEjecucionUnidadProceso] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_EnrutamientoTblEjecucionUnidadProceso_IDUsuario]
GO
