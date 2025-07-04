USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblSolicitudPosiciones](
	[IDSolicitudPosiciones] [int] IDENTITY(1,1) NOT NULL,
	[IDPlaza] [int] NULL,
	[FechaReg] [datetime] NULL,
	[SolicitudDisponibleDesde] [date] NULL,
	[SolicitudDisponibleHasta] [date] NULL,
	[SolicitudNumeroPosiciones] [int] NULL,
	[SolicitudIsTemporal] [bit] NULL,
	[IsActive] [bit] NULL,
	[IDUsuario] [int] NULL,
 CONSTRAINT [Pk_RHtblSolicitudPosiciones_IDSolicitudPosiciones] PRIMARY KEY CLUSTERED 
(
	[IDSolicitudPosiciones] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblSolicitudPosiciones]  WITH CHECK ADD  CONSTRAINT [FK_RHtblSolicitudPosiciones_RHtblCatPlazas_IDPlaza] FOREIGN KEY([IDPlaza])
REFERENCES [RH].[tblCatPlazas] ([IDPlaza])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblSolicitudPosiciones] CHECK CONSTRAINT [FK_RHtblSolicitudPosiciones_RHtblCatPlazas_IDPlaza]
GO
